# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Validators.app (https://www.validators.app/) is a Rails 6.1 app that tracks and scores Solana
validators. It ingests data from Solana RPC nodes (mainnet, testnet, alpenglow-community) via
long-running daemons, stores it in MySQL, computes validator scores/stats in background jobs, and
serves a web UI + JSON API on top of it.

## Common commands

Run the app (Rails server + Sidekiq via foreman):
```
./bin/dev
```

Tests (Minitest, not RSpec):
```
rails test                                  # full suite
rails test test/models                      # a directory
rails test test/models/article_test.rb      # a file
rails test test/models/article_test.rb:6    # a single test by line
```
If yarn/asset errors show up locally: `rake assets:clobber && yarn install`.

JS tests:
```
yarn test        # jest
```

Lint (Rubocop, config in `.rubocop.yml`, target Ruby 2.7/Rails 6.1 rules, `DisabledByDefault: true`
so only explicitly-enabled cops run):
```
bundle exec rubocop
```
PR-level lint is done via Pronto (`.pronto.yml`, uses `pronto-rubocop` + `pronto-flay`) in CI.

DB setup:
```
rails db:create
rails db:migrate
rails db:seed
```
There are **two databases** configured per environment (see `config/database.yml`): `primary` and
`blockchain` (own migrations path `db/blockchain_migrate`). Blockchain-specific models/migrations
go through the `blockchain` connection, everything else uses `primary`.

## Architecture

### Two data domains, two databases, two Sidekiq queues

- **Primary DB / default Sidekiq queues** (`high_priority`, `default`, `low_priority`,
  `lowest_priority`, config in `config/sidekiq.yml`) — validators, scores, stake accounts, ping
  data, data centers, users, etc.
- **Blockchain DB / blockchain Sidekiq queues** (`blockchain_mainnet`, `blockchain_testnet`,
  `blockchain`, config in `config/sidekiq_blockchain.yml`) — raw chain data: blocks, slots,
  transactions, per network, each with a matching `*_archive` model (e.g.
  `app/models/blockchain/mainnet_block.rb` / `mainnet_block_archive.rb`). Recent data lives in the
  main table; older data is moved to the archive table/DB to keep the hot table small.

Both Sidekiq processes are started by `Procfile.dev` (`sidekiq` and `sidekiq_blockchain`) alongside
`web`.

### Daemons: how chain data gets in

`daemons/*.rb` are standalone long-running Ruby scripts (not Rails jobs) that `require_relative
'../config/environment'` and loop indefinitely, polling Solana RPC endpoints and pushing work into
Sidekiq. They're supervised as system services in production (see `daemons/blockchain/*.service`).
Examples:
- `gather_rpc_mainnet_daemon.rb` / `gather_rpc_testnet_daemon.rb` / `gather_rpc_alpenglow_community_daemon.rb`
  — pull validator/vote-account/epoch data per network on a sleep loop, then enqueue follow-up
  workers (`BuildSkippedSlotPercentWorker`, `ReportSoftwareVersionWorker`, ...).
- `validator_score_mainnet_v1_daemon.rb` / `*_testnet_v1_daemon.rb` / `*_alpenglow_community_v1_daemon.rb`
  — trigger validator scoring runs per network.
- `daemons/blockchain/archive_blockchain_daemon.rb`, `slot_subscribe_mainnet_daemon.rb`,
  `slot_subscribe_testnet_daemon.rb` — chain block/slot ingestion and archiving.
- `daemons/concerns/` — shared helpers (leader stats, front-end stats constants) `include`d into
  daemons.
- Each network is configured via `NETWORKS` / `NETWORK_URLS` in
  `config/initializers/solana_networks.rb`, backed by `Rails.application.credentials.solana`.

### The Pipeline pattern

Most data-processing logic (in `app/logic/*_logic.rb`) is built as a chain of steps run through a
`Pipeline` struct (`code`, `payload`, `message`, `errors`, defined in
`config/initializers/pipeline.rb`) — a railway-oriented style:
```ruby
Pipeline.new(200, payload)
        .then(&step_one)
        .then(&step_two)
        .then(&step_three)
```
Every step is a method returning a `lambda { |p| ... }` that:
- immediately returns `p` unchanged if `p.code != 200` (short-circuits on earlier failure),
- does its work and returns a new `Pipeline.new(200, p.payload.merge(...))` on success,
- rescues into `Pipeline.new(5xx, p.payload, 'message', exception)` on failure, usually also
  reporting to Appsignal.

`PipelineLogic` (`app/logic/pipeline_logic.rb`) holds cross-cutting steps like `log_errors`, plus
global helpers `array_average`/`array_median` and an `ActiveRecord::Base.median` monkey-patch.
When touching scoring/ingestion logic, follow this same shape rather than introducing a different
control-flow style — daemons and workers are built assuming pipeline steps are idempotent-ish,
side-effect at the end, and always return a `Pipeline`.

### Validator scoring

`app/logic/validator_score_v1_logic.rb` (`ValidatorScoreV1Logic`) is the core scoring pipeline,
run per network per batch (`Batch` model, identified by `network` + `batch_uuid`). It:
1. loads the batch and all active validators for the network (creating a `ValidatorScoreV1` row
   per validator if missing),
2. compares each validator's root/vote distance against cluster-wide average/median
   (`Stats::ValidatorHistory`, `Stats::VoteAccountHistory`, `Stats::ValidatorBlockHistory` in
   `app/models/stats/`) to assign 0-2 point sub-scores (`root_distance_score`,
   `vote_distance_score`, `skipped_slot_score`, `skipped_after_score`, `stake_concentration_score`),
3. determines the "current" software version per client by cumulative stake share (66% threshold)
   and scores validators against it,
4. persists everything back onto `Validator` / `ValidatorScoreV1` in one transaction.
Related: `app/logic/stake_logic.rb` (stake concentration/pools), `app/logic/gossip_node_logic.rb`,
`app/logic/asn_logic.rb`, `app/logic/solana_logic.rb` (RPC batch fetch steps used by the gather
daemons), `app/logic/report_logic.rb`.

### Services, workers, queries

- `app/services/` — single-purpose service objects (`*_service.rb`) invoked from workers/daemons/
  controllers, e.g. `create_cluster_stats_service.rb`, `total_rewards_update_service.rb`,
  `track_commission_changes_service.rb`. Subfolders group by domain (`blockchain/`,
  `cluster_stats/`, `data_centers/`, `sol_prices/`, `stake_pools/`, `validator_ips/`, `gatherers/`).
- `app/workers/` — Sidekiq workers, thin wrappers that call into `app/logic` or `app/services`.
  `app/workers/blockchain/` holds workers that must run on the blockchain queues.
- `app/queries/` — read-only query objects (`*_query.rb`) used by controllers/views instead of
  scopes living directly on models, e.g. `validator_query.rb`, `validator_score_query.rb`.
- `app/api_clients/` — thin wrappers around external HTTP APIs (CoinGecko, MaxMind).
- `script/` — one-off/maintenance scripts run via `rails runner` (backfills, rebuilds, prunes),
  not part of the request/job lifecycle. `dev/` holds similar scripts intended for local/manual use
  only.

### Web/API surface

- `app/controllers/api/v1/` — versioned JSON API (validators, stake accounts, ping data, data
  centers, policies, gossip nodes, etc.), separate from the HTML controllers at `app/controllers/`
  root (`validators_controller.rb`, `data_centers_controller.rb`, `map_controller.rb`, ...).
- Devise handles auth (`sessions_controller.rb` overrides the sessions controller); the Sidekiq
  web UI is mounted and restricted to admins (see `config/routes.rb`).
- Frontend is Webpacker + Vue 2 (`bootstrap-vue`) plus some plain JS packs
  (`app/javascript/src/*.js`) and Chart.js for graphs; `@solana/web3.js` / `@solana/kit` are used
  client-side for chain interaction where relevant.

## Notes specific to this codebase

- Multi-network by convention: most models/tables carry a `network` column
  (`mainnet`/`testnet`/`alpenglow-community`) rather than using separate tables per network for
  application data; blockchain-domain models are the exception (separate `Mainnet*`/`Testnet*`
  classes/tables per network).
- Attribute encryption (`attr_encrypted`) is required for any personally-identifying or sensitive
  attribute on a model; the key lives in Rails credentials.
- Solana CLI is a real system dependency for some services/scripts (not just the RPC gems) — since
  v3 it must be built from source (see README for the current install instructions).
- Test credentials are encrypted (`config/credentials/test.yml.enc`); CI decrypts
  `config/credentials/test.key` from `config/credentials/test_key.gpg` via
  `.github/scripts/decrypt_test_key.sh`. Tests use VCR (`test/vcr_cassettes/`) for HTTP interactions
  and DatabaseCleaner truncation between tests (parallelization is explicitly disabled:
  `parallelize(workers: 1)` in `test/test_helper.rb`).

### General Instructions
- Always use polish language in conversation
- Do not write comments in code