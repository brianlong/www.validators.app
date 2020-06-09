# frozen_string_literal: true

# SolanaLogic contains methods used for importing data from the solana runtime.
# Many of these methods are simple wrappers for shell commands. These methods
# are lambdas that we can use in a processing pipeline for various purposes.
#
# See `config/initializers/pipeline.rb` for a description of the Pipeline struct
module SolanaLogic
  include PipelineLogic

  # validators_get returns the data from RPC 'getClusterNodes'
  def validators_get
    lambda do |p|
      return p unless p[:code] == 200

      validators_json = rpc_request(
        'getClusterNodes',
        p[:payload][:config_url]
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

      Pipeline.new(200, p[:payload].merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from validators_get', e)
    end
  end

  # vote_accounts_get returns the data from RPC 'getVoteAccounts'
  def vote_accounts_get
    lambda do |p|
      return p unless p[:code] == 200

      vote_accounts_json = rpc_request(
        'getVoteAccounts',
        p[:payload][:config_url]
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

      Pipeline.new(200, p[:payload].merge(vote_accounts: vote_accounts))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from vote_accounts_get', e)
    end
  end

  # reduce the two validators and vote_accounts Hashes into a single structure
  def reduce_validator_vote_accounts
    lambda do |p|
      return p unless p[:code] == 200

      validators_reduced = {}
      p[:payload][:validators].each do |k, _v|
        next if p[:payload][:vote_accounts][k].nil?

        validators_reduced[k] = \
          p[:payload][:validators][k].merge(p[:payload][:vote_accounts][k])
      end

      Pipeline.new(
        200,
        p[:payload].merge(validators_reduced: validators_reduced)
      )
    rescue StandardError => e
      Pipeline.new(
        500,
        p[:payload],
        'Error from reduce_validator_vote_accounts',
        e
      )
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
        vote_account.vote_account_histories.create(
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

      Pipeline.new(200, p[:payload])
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'Error from validators_save', e)
    end
  end

  def validator_block_history_get
    lambda do |p|
      return p unless p[:code] == 200

      solana_path = \
        if Rails.env.production?
          '/home/deploy/.local/share/solana/install/active_release/bin/'
        else
          ''
        end
      block_history_json = `#{solana_path}solana block-production \
                              --output json \
                              --url #{p[:payload][:config_url]}`
      block_history = JSON.parse(block_history_json)

      # Data for the validator_block_history_stats table
      batch_id = SecureRandom.uuid
      epoch = block_history['epoch']
      block_history_stats = {
        'batch_id' => batch_id,
        'epoch' => epoch,
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
          'batch_id' => batch_id,
          'epoch' => epoch,
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
        # puts "#{h['slot']} => #{this_leader}"
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
          # puts "  #{skipped_slots_after_leader}"

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
      payload_1 = p[:payload] \
                  .merge(validator_block_history: validator_block_history)
      Pipeline.new(
        200,
        payload_1.merge(validator_block_history_stats: block_history_stats)
      )
    rescue StandardError => e
      Pipeline.new(
        500,
        p[:payload],
        'Error from validator_block_history_get',
        e
      )
    end
  end

  def validator_block_history_save
    lambda do |p|
      return p unless p[:code] == 200

      stats = p[:payload][:validator_block_history_stats]
      ValidatorBlockHistoryStat.create(
        batch_id: stats['batch_id'],
        epoch: stats['epoch'],
        start_slot: stats['start_slot'],
        end_slot: stats['end_slot'],
        total_slots: stats['total_slots'],
        total_blocks_produced: stats['total_blocks_produced'],
        total_slots_skipped: stats['total_slots_skipped']
      )

      # byebug
      p[:payload][:validator_block_history].each do |k, v|
        validator = Validator.where(
          network: p[:payload][:network],
          account: k
        ).first
        next if validator.nil?

        validator.validator_block_histories.create(
          batch_id: v['batch_id'],
          epoch: v['epoch'],
          leader_slots: v['leader_slots'],
          blocks_produced: v['blocks_produced'],
          skipped_slots: v['skipped_slots'],
          skipped_slot_percent: v['skipped_slot_percent'].round(4),
          skipped_slots_after: v['skipped_slots_after'],
          skipped_slots_after_percent:
            (v['skipped_slots_after'] / v['leader_slots'].to_f)
        )
      end

      Pipeline.new(200, p[:payload])
    rescue StandardError => e
      Pipeline.new(
        500,
        p[:payload],
        'Error from validator_block_history_save',
        e
      )
    end
  end

  # rpc_request will make a Solana RPC request and return the results in a
  # JSON object. API specifications are at:
  #   https://docs.solana.com/apps/jsonrpc-api#json-rpc-api-reference
  def rpc_request(rpc_method, rpc_url)
    # Parse the URL data into an URI object
    uri = URI.parse(
      "#{rpc_url}:#{Rails.application.credentials.solana[:rpc_port]}"
    )

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

    JSON.parse(response.body)
  end
end
