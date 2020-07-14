# frozen_string_literal: true

require 'timeout'

# SolanaLogic contains methods used for importing data from the solana runtime.
# Many of these methods are simple wrappers for shell commands. These methods
# are lambdas that we can use in a processing pipeline for various purposes.
#
# See `config/initializers/pipeline.rb` for a description of the Pipeline struct
module SolanaLogic
  include PipelineLogic
  RPC_TIMEOUT = 7 # seconds

  # Create a batch record and set the :batch_uuid in the payload
  def batch_set
    lambda do |p|
      batch = Batch.create!(network: p.payload[:network])

      Pipeline.new(200, p.payload.merge(batch_uuid: batch.uuid))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from batch_set', e)
    end
  end

  # At the end of a pipeline operation, we can modify batch.updated_at to
  # calculate batch processing time.
  def batch_touch
    lambda do |p|
      # byebug
      batch = Batch.where(uuid: p.payload[:batch_uuid]).first
      batch&.touch # instead of batch.touch if batch

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from batch_touch', e)
    end
  end

  def epoch_get
    lambda do |p|
      epoch_json = rpc_request(
        'getEpochInfo',
        p.payload[:config_urls]
      )['result']

      epoch = EpochHistory.create(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        epoch: epoch_json['epoch'],
        current_slot: epoch_json['absoluteSlot'],
        slot_index: epoch_json['slotIndex'],
        slots_in_epoch: epoch_json['slotsInEpoch']
      )

      Pipeline.new(200, p.payload.merge(epoch: epoch.epoch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from epoch_get', e)
    end
  end

  # Use the Solana CLI tool to get Validator information
  def validators_cli
    lambda do |p|
      return p unless p[:code] == 200

      validators = cli_request('validators', p.payload[:config_urls])

      raise 'No results from `solana validators`' if validators.nil?

      raise 'No results from `solana validators`' if \
        validators['currentValidators'].empty? &&
        validators['delinquentValidators'].empty?

      # Create current validators
      validators['currentValidators'].each do |validator|
        ValidatorHistory.create(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid],
          account: validator['identityPubkey'],
          vote_account: validator['voteAccountPubkey'],
          commission: validator['commission'],
          last_vote: validator['lastVote'],
          root_block: validator['rootSlot'],
          credits: validator['credits'],
          active_stake: validator['activatedStake']
        )
      end

      # Create delinquent validators
      validators['delinquentValidators'].each do |validator|
        ValidatorHistory.create(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid],
          account: validator['identityPubkey'],
          vote_account: validator['voteAccountPubkey'],
          commission: validator['commission'],
          last_vote: validator['lastVote'],
          root_block: validator['rootSlot'],
          credits: validator['credits'],
          active_stake: validator['activatedStake'],
          delinquent: true
        )
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from validators_cli', e)
    end
  end

  # validators_get returns the data from RPC 'getClusterNodes'
  def validators_get
    lambda do |p|
      return p unless p[:code] == 200

      validators_json = rpc_request(
        'getClusterNodes',
        p.payload[:config_urls]
      )['result']

      validators = {}
      validators_json.each do |hash|
        validators[hash['pubkey']] = {
          'gossip_ip_port' => hash['gossip'],
          'rpc_ip_port' => hash['rpc'],
          'tpu_ip_port' => hash['tpu'],
          'version' => hash['version']
        }
      end

      Pipeline.new(200, p.payload.merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from validators_get', e)
    end
  end

  # vote_accounts_get returns the data from RPC 'getVoteAccounts'
  def vote_accounts_get
    lambda do |p|
      return p unless p[:code] == 200

      vote_accounts_json = rpc_request(
        'getVoteAccounts',
        p.payload[:config_urls]
      )['result']['current']

      vote_accounts = {}
      vote_accounts_json.each do |hash|
        vote_accounts[hash['nodePubkey']] = {
          'vote_account' => hash['votePubkey'],
          'activated_stake' => hash['activatedStake'],
          'commission' => hash['commission'],
          'last_vote' => hash['lastVote'],
          'credits' => hash['epochCredits'][-1][1]
        }
      end

      Pipeline.new(200, p.payload.merge(vote_accounts: vote_accounts))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from vote_accounts_get', e)
    end
  end

  # reduce the two validators and vote_accounts Hashes into a single structure
  def reduce_validator_vote_accounts
    lambda do |p|
      return p unless p[:code] == 200

      validators_reduced = {}
      p.payload[:validators].each do |k, _v|
        next if p.payload[:vote_accounts][k].nil?

        validators_reduced[k] = \
          p.payload[:validators][k].merge(p.payload[:vote_accounts][k])
      end

      Pipeline.new(
        200,
        p.payload.merge(validators_reduced: validators_reduced)
      )
    rescue StandardError => e
      Pipeline.new(
        500,
        p.payload,
        'Error from reduce_validator_vote_accounts',
        e
      )
    end
  end

  # Save data to the DB
  def validators_save
    lambda do |p|
      return p unless p[:code] == 200

      p.payload[:validators_reduced].each do |k, v|
        # Find or create the validator record
        validator = Validator.find_or_create_by(
          network: p.payload[:network],
          account: k
        )

        # Find or create the vote_account record
        vote_account = validator.vote_accounts.find_or_create_by(
          account: v['vote_account']
        )

        # Create Vote records to save a time series of vote & stake data
        vote_account.vote_account_histories.create(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid],
          commission: v['commission'],
          last_vote: v['last_vote'],
          credits: v['credits'],
          activated_stake: v['activated_stake'],
          software_version: v['version']
        )

        # Find or create the validator IP address
        _ip = validator.validator_ips.find_or_create_by(
          version: 4,
          address: v['gossip_ip_port'].split(':')[0]
        )
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from validators_save', e)
    end
  end

  def validator_block_history_get
    lambda do |p|
      return p unless p[:code] == 200

      block_history = cli_request('block-production', p.payload[:config_urls])

      raise 'No data from block-production' if block_history.nil?

      # Data for the validator_block_history_stats table
      block_history_stats = {
        'batch_uuid' => p.payload[:batch_uuid],
        'epoch' => p.payload[:epoch],
        'start_slot' => block_history['start_slot'],
        'end_slot' => block_history['end_slot'],
        'total_slots' => block_history['total_slots'],
        'total_blocks_produced' => \
          block_history['total_blocks_produced'],
        'total_slots_skipped' => \
          block_history['total_slots_skipped']
      }

      # Leaders
      validator_block_json = block_history['leaders']
      validator_block_history = {}
      validator_block_json.each do |v|
        validator_block_history[v['identityPubkey']] = {
          'batch_uuid' => p.payload[:batch_uuid],
          'epoch' => p.payload[:epoch],
          'leader_slots' => v['leaderSlots'],
          'blocks_produced' => v['blocksProduced'],
          'skipped_slots' => v['skippedSlots'],
          'skipped_slot_percent' => v['skippedSlots'] / v['leaderSlots'].to_f,
          'skipped_slots_after' => 0,
          'skipped_slots_after_percent' => 0.0
        }
      end

      # Loop through the slots to accumulate stats
      prior_leader = nil
      current_leader = nil
      i = 0
      # byebug
      block_history['individual_slot_status'].each do |h|
        this_leader = h['leader']
        if this_leader == current_leader
          # We have the same leader
        else
          # We have a new leader
          prior_leader = current_leader
          current_leader = this_leader
          # calculate the stats for the prior leader
          # The prior leaders slots ended at i-1
          # if /26AT/.match prior_leader
          #   puts "  PRIOR LEADER: #{prior_leader}"
          #   puts "  NEW LEADER: #{current_leader}"
          #   puts "  #{block_history['individual_slot_status'][i..i + 3].map { |s| s['skipped'] }}"
          # end
          skipped_slots_after_leader = \
            block_history['individual_slot_status'][i..i + 3].count do |s|
              s['skipped'] == true
            end

          if prior_leader.nil?
            i += 1
            next
          end

          validator_block_history[prior_leader]['skipped_slots_after'] += \
            skipped_slots_after_leader
        end

        i += 1
      end
      # Done looping through the slots to accumulate stats

      # byebug
      payload_1 = p.payload \
                   .merge(validator_block_history: validator_block_history)
      Pipeline.new(
        200,
        payload_1.merge(validator_block_history_stats: block_history_stats)
      )
    rescue StandardError => e
      Pipeline.new(
        500,
        p.payload,
        'Error from validator_block_history_get',
        e
      )
    end
  end

  def validator_block_history_save
    lambda do |p|
      return p unless p[:code] == 200

      stats = p.payload[:validator_block_history_stats]
      ValidatorBlockHistoryStat.create(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        epoch: p.payload[:epoch],
        start_slot: stats['start_slot'],
        end_slot: stats['end_slot'],
        total_slots: stats['total_slots'],
        total_blocks_produced: stats['total_blocks_produced'],
        total_slots_skipped: stats['total_slots_skipped']
      )

      # byebug
      p.payload[:validator_block_history].each do |k, v|
        validator = Validator.where(
          network: p.payload[:network],
          account: k
        ).first
        next if validator.nil?

        validator.validator_block_histories.create(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid],
          epoch: p.payload[:epoch],
          leader_slots: v['leader_slots'],
          blocks_produced: v['blocks_produced'],
          skipped_slots: v['skipped_slots'],
          skipped_slot_percent: v['skipped_slot_percent'].round(4),
          skipped_slots_after: v['skipped_slots_after'],
          skipped_slots_after_percent:
            (v['skipped_slots_after'] / v['leader_slots'].to_f)
        )
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(
        500,
        p.payload,
        'Error from validator_block_history_save',
        e
      )
    end
  end

  # rpc_request will make a Solana RPC request and return the results in a
  # JSON object. API specifications are at:
  #   https://docs.solana.com/apps/jsonrpc-api#json-rpc-api-reference
  def rpc_request(rpc_method, rpc_urls)
    # Parse the URL data into an URI object.
    # The mainnet RPC endpoint is not on port 8899. I am now including the port
    # with the URL inside of Rails credentials.
    # uri = URI.parse(
    #   "#{rpc_url}:#{Rails.application.credentials.solana[:rpc_port]}"
    # )

    rpc_urls.each do |rpc_url|
      uri = URI.parse(rpc_url)

      response_body = Timeout.timeout(RPC_TIMEOUT) do
        # Create the HTTP session and send the request
        response = Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Post.new(
            uri.request_uri,
            { 'Content-Type' => 'application/json' }
          )
          request.body = {
            'jsonrpc': '2.0', 'id': 1, 'method': rpc_method.to_s
          }.to_json
          http.request(request)
        end

        response.body
      rescue Errno::ECONNREFUSED, Timeout::Error => e
        Rails.logger.error "RPC ERROR\n#{e.class}\nRPC URL: #{rpc_url}"
        nil
      end

      return JSON.parse(response_body) if response_body
    rescue JSON::ParserError => e
      Rails.logger.error "RPC ERROR\n#{e.class}\nRPC URL: #{rpc_url}"
    end
  end

  # cli_request will accept a command line command to run and then return the
  # results as parsed JSON. nil is returned if there is no data
  def cli_request(cli_method, rpc_urls)
    solana_path = \
      if Rails.env.production?
        '/home/deploy/.local/share/solana/install/active_release/bin/'
      else
        ''
      end

    rpc_urls.each do |rpc_url|
      response_json = Timeout.timeout(RPC_TIMEOUT) do
        `#{solana_path}solana #{cli_method} --output json --url #{rpc_url}`

      rescue Errno::ECONNREFUSED, Timeout::Error => e
        Rails.logger.error "RPC ERROR\n#{e.class}\nRPC URL: #{rpc_url}"
        ''
      end

      return JSON.parse(response_json) unless response_json == ''
    rescue JSON::ParserError => e
      Rails.logger.error "RPC ERROR\n#{e.class}\nRPC URL: #{rpc_url}"
    end
    nil
  end
end
