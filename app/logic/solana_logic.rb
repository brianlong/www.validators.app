# frozen_string_literal: true

# SolanaLogic contains methods used for importing data from the solana runtime.
# Many of these methods are simple wrappers for shell commands. These methods
# are lambdas that we can use in a processing pipeline for various purposes.
#
# See `config/initializers/pipeline.rb` for a description of the Pipeline struct
module SolanaLogic
  # validators will return a validators Hash with the identity account as the
  # key. and the contents of the shell command results as the values.
  def validators_get
    lambda do |p|
      return p unless p[:code] == 200

      validators_array = \
        JSON.parse(`solana validators --url #{p[:payload][:config_url]} \
                    --output json-compact`)['currentValidators']

      # Sample Output
      # {"activatedStake"=>49307292744891, "commission"=>100,
      # "credits"=>8819521,
      # "identityPubkey"=>"Ft5fbkqNa76vnsjYNwjDZUXoTWpP7VYm3mtsaQckQADN",
      # "lastVote"=>15251252, "rootSlot"=>15251214,
      # "voteAccountPubkey"=>"Dht9r8gKos3p7wAQP4tFPb7VxsQT48y8ZfvxxeRa8eTT"}
      validators = {}
      validators_array.each do |hash|
        validators[hash['identityPubkey']] = {
          'vote_account' => hash['voteAccountPubkey'],
          'activated_stake' => hash['activatedStake'],
          'commission' => hash['commission'],
          'credits' => hash['credits'],
          'last_vote' => hash['lastVote'],
          'root_slot' => hash['rootSlot']
        }
      end
      Pipeline.new(200, p[:payload].merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from validators_get', e)
    end
  end

  # gossip returns the data from `solana gossip`
  def gossip_get
    lambda do |p|
      return p unless p[:code] == 200

      gossip_json = rpc_request(
        'getClusterNodes',
        p[:payload][:config_url]
      )['result']

      # Sample output:
      # {"gossip"=>"216.24.140.155:8001",
      # "pubkey"=>"5D1fNXzvv5NjV1ysLjirC4WY92RNsVH18vjmcszZd8on",
      # "rpc"=>"216.24.140.155:8899", "tpu"=>"216.24.140.155:8004",
      # "version"=>"1.1.14 c7d85758"}
      gossip = {}
      gossip_json.each do |hash|
        gossip[hash['pubkey']] = {
          'gossip_ip_port' => hash['gossip'],
          'rpc_ip_port' => hash['rpc'],
          'tpu_ip_port' => hash['tpu'],
          'version' => hash['version']
        }
      end

      Pipeline.new(200, p[:payload].merge(gossip: gossip))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from gossip_get', e)
    end
  end

  # reduce the two validators and gossip Hashes into a single structure
  def reduce_gossip_validators
    lambda do |p|
      return p unless p[:code] == 200

      validators_reduced = {}
      p[:payload][:validators].each do |k, _v|
        validators_reduced[k] = \
          p[:payload][:validators][k].merge(p[:payload][:gossip][k])
      end

      Pipeline.new(
        200,
        p[:payload].merge(validators_reduced: validators_reduced)
      )
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from reduce_gossip_validators', e)
    end
  end

  # Save data to the DB
  def validators_save
    lambda do |p|
      return p unless p[:code] == 200

      p[:payload][:validators_reduced].each do |k, v|
        # Find or create the validator record
        validator = Validator.find_or_create_by(
          network: p[:payload][:network],
          account: k
        )

        # Find or create the vote_account record
        vote_account = validator.vote_accounts.find_or_create_by(
          account: v['vote_account']
        )

        # Create Vote records to save a time series of vote & stake data
        vote_account.votes.create(
          commission: v['commission'],
          last_vote: v['last_vote'],
          root_slot: v['root_slot'],
          credits: v['credits'],
          activated_stake: v['activated_stake'],
          software_version: v['version']
        )

        # byebug
        # Find or create the validator IP address
        _ip = validator.validator_ips.find_or_create_by(
          version: 4,
          address: v['gossip_ip_port'].split(':')[0]
        )
      end

      Pipeline.new(200, p[:payload])
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from validators_save', e)
    end
  end

  # rpc_request will make a Solana RPC request and return the results in a
  # JSON object. API specifications are at:
  #
  #   https://docs.solana.com/apps/jsonrpc-api#json-rpc-api-reference
  def rpc_request(rpc_method, rpc_url)
    JSON.parse(`curl -X POST -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0", "id":1, "method":"#{rpc_method}"}' #{rpc_url}`)
  end
end
