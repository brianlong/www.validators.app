# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/gather_rpc_data.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_urls: Rails.application.credentials.solana[:testnet_urls],
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&batch_set)
            .then(&epoch_get)
            .then(&validators_cli)
            .then(&validators_get)
            .then(&vote_accounts_get)
            .then(&reduce_validator_vote_accounts)
            .then(&validators_save)
            .then(&validator_block_history_get)
            .then(&validator_block_history_save)
            .then(&log_errors)
            .then(&batch_touch)

if p.code == 200
  BuildSkippedSlotPercentWorker.perform_async(
    network: p.payload[:network],
    batch_uuid: p.payload[:batch_uuid]
  )
  BuildSkippedAfterPercentWorker.perform_async(
    network: p.payload[:network],
    batch_uuid: p.payload[:batch_uuid]
  )
  ChartHomePageWorker.perform_async(
    batch_uuid: p.payload[:batch_uuid],
    network: p.payload[:network],
    epoch: p.payload[:epoch]
  )
  ReportTowerHeightWorker.perform_async(
    epoch: p.payload[:epoch],
    batch_uuid: p.payload[:batch_uuid],
    network: p.payload[:network]
  )
  ReportSoftwareVersionWorker.perform_async(
    batch_uuid: p.payload[:batch_uuid],
    network: p.payload[:network]
  )
  FeedZoneWorker.perform_async(
    network: p.payload[:network],
    batch_uuid: p.payload[:batch_uuid]
  )
  ValidatorScoreV1Worker.perform_async(
    network: p.payload[:network],
    batch_uuid: p.payload[:batch_uuid]
  )
end
