# frozen_string_literal: true

require 'timeout'

# SolanaLogic contains methods used for importing data from the solana runtime.
# Many of these methods are simple wrappers for shell commands. These methods
# are lambdas that we can use in a processing pipeline for various purposes.
#
# See `config/initializers/pipeline.rb` for a description of the Pipeline struct
module SolanaLogic
  include PipelineLogic
  include SolanaRequestsLogic

  # Create a batch record and set the :batch_uuid in the payload
  def batch_set
    lambda do |p|
      batch = Batch.create!(network: p.payload[:network])

      Pipeline.new(200, p.payload.merge(batch_uuid: batch.uuid))
    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from batch_set', e)
    end
  end

  # At the end of a pipeline operation, we can modify batch.gathered_at to
  # calculate batch processing time.
  # We can also set some attributes ie. skipped_slot_all_average.
  def batch_touch
    lambda do |p|
      batch = Batch.where(uuid: p.payload[:batch_uuid], network: p.payload[:network]).first

      # IMPORTANT: Do not use this values on index page, it's only for show.
      average_skipped_slot_percent = Stats::ValidatorBlockHistory.new(
        p.payload[:network], p.payload[:batch_uuid]
      ).average_skipped_slot_percent

      average_skipped_after_percent = Stats::ValidatorBlockHistory.new(
        p.payload[:network], p.payload[:batch_uuid]
      ).average_skipped_slots_after_percent

      batch&.skipped_slot_all_average = average_skipped_slot_percent
      batch&.skipped_after_all_average = average_skipped_after_percent

      ##### /IMPORTANT
      batch&.gathered_at = Time.now # instead of batch.touch if batch
      batch&.save

      Pipeline.new(200, p.payload)
    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from batch_touch', e)
    end
  end

  def epoch_get
    lambda do |p|
      epoch_json = solana_client_request(
        p.payload[:config_urls],
        :get_epoch_info
      )

      epoch = EpochHistory.create(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        epoch: epoch_json['epoch'],
        current_slot: epoch_json['absoluteSlot'],
        slot_index: epoch_json['slotIndex'],
        slots_in_epoch: epoch_json['slotsInEpoch']
      )

      Pipeline.new(200, p.payload.merge(
                          epoch: epoch.epoch,
                          epoch_slot_index: epoch.slot_index
                        ))
    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from epoch_get', e)
    end
  end

  # Use the Solana CLI tool to update ValidatorHistory information
  def validator_history_update
    lambda do |p|
      return p unless p[:code] == 200

      validators_cli = cli_request('validators', p.payload[:config_urls])

      raise 'No results from `solana validators`' if validators_cli.blank?

      raise 'No results from `solana validators`' if validators_cli['validators'].blank?

      # There were recent updates to the validators CLI response. This is the
      # response struct as of 2021-07-25.
      # "validators": [
      #   {
      #     "identityPubkey": "5bBECyn9rNvcTB8y9j2Rzs3myXUDR97m62oaJong8sg2",
      #     "voteAccountPubkey": "5BTgeYMDUQz59sdNFr47FVmA119QmsoZNjUyGyeGb4sJ",
      #     "commission": 2,
      #     "lastVote": 88545169,
      #     "rootSlot": 88545120,
      #     "credits": 7409369,
      #     "epochCredits": 156357,
      #     "activatedStake": 404510903886025,
      #     "version": "1.6.10",
      #     "delinquent": false,
      #     "skipRate": 37.745098039215684
      #   },

      max_root_height = validators_cli['validators'].map { |v|
        v['rootSlot']
      }.max.to_i

      max_vote_height = validators_cli['validators'].map { |v|
        v['lastVote']
      }.max.to_i

      validator_histories = {}

      existing_validators(validators_cli["validators"], p.payload[:network]).each do |validator|
        next if Rails.application.config.validator_blacklist[p.payload[:network]].include? validator["identityPubkey"]

        if existing_history = validator_histories[validator["identityPubkey"]]
          if existing_history.last_vote < validator["lastVote"]
            existing_history.update(
              account: validator["identityPubkey"],
              vote_account: validator["voteAccountPubkey"],
              commission: validator["commission"],
              last_vote: validator["lastVote"],
              root_block: validator["rootSlot"],
              credits: validator["credits"],
              epoch_credits: validator["epochCredits"],
              epoch: p.payload[:epoch],
              active_stake: validator["activatedStake"],
              software_version: (p.payload[:validators]&.fetch(validator["identityPubkey"])&.fetch('version') || validator['version']),
              software_client: (p.payload[:validators]&.fetch(validator["identityPubkey"])&.fetch('client') || 'Unknown'),
              delinquent: validator["delinquent"],
              slot_skip_rate: validator["skipRate"],
              root_distance: max_root_height - validator["rootSlot"].to_i,
              vote_distance: max_vote_height - validator["lastVote"].to_i,
              max_root_height: max_root_height,
              max_vote_height: max_vote_height,
              validator_id: validator["id"]
            )

            validator_histories[validator["identityPubkey"]] = existing_history
          end
        else
          vh = ValidatorHistory.create(
            network: p.payload[:network],
            batch_uuid: p.payload[:batch_uuid],
            account: validator["identityPubkey"],
            vote_account: validator["voteAccountPubkey"],
            commission: validator["commission"],
            last_vote: validator["lastVote"],
            root_block: validator["rootSlot"],
            credits: validator["credits"],
            epoch_credits: validator["epochCredits"],
            epoch: p.payload[:epoch],
            active_stake: validator["activatedStake"],
            software_version: (p.payload[:validators]&.fetch(validator["identityPubkey"])&.fetch('version') || validator['version']),
            software_client: (p.payload[:validators]&.fetch(validator["identityPubkey"])&.fetch('client') || 'Unknown'),
            delinquent: validator["delinquent"],
            slot_skip_rate: validator["skipRate"],
            root_distance: max_root_height - validator["rootSlot"].to_i,
            vote_distance: max_vote_height - validator["lastVote"].to_i,
            max_root_height: max_root_height,
            max_vote_height: max_vote_height,
            validator_id: validator["id"]
          )
          validator_histories[validator["identityPubkey"]] = vh
        end
      end

      Pipeline.new(200, p.payload)

    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from validator_history_update", e)
    end
  end

  # validators_get returns the data from RPC 'getClusterNodes'
  def validators_get
    lambda do |p|
      return p unless p[:code] == 200

      validators_json = solana_client_request(
        p.payload[:config_urls],
        :get_cluster_nodes
      )

      validators = {}
      validators_json.each do |hash|
        next if Rails.application.config.validator_blacklist[p.payload[:network]].include? hash["pubkey"]

        validators[hash['pubkey']] = {
          'gossip_ip_port' => hash['gossip'],
          'rpc_ip_port' => hash['rpc'],
          'tpu_ip_port' => hash['tpu'],
          'version' => hash['version'].match(/^[a-zA-z0-9.]+ /).to_s.strip,
          'client' => hash['version'].match(/client:[a-zA-Z]+/).to_s.gsub('client:', '')
        }
      end

      Pipeline.new(200, p.payload.merge(validators: validators))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from validators_get', e)
    end
  end

  # Fetches program accounts, default program is config,
  # where you can check if signer is true for the validator.
  # More program pubkeys can be found on
  # https://docs.solana.com/developing/runtime-facilities/programs
  def program_accounts(
    config_program_pubkey: 'Config1111111111111111111111111111111111111',
    encoding: 'jsonParsed'
  )
    lambda do |p|
      return p unless p[:code] == 200

      config_program_pubkey = config_program_pubkey
      params = [config_program_pubkey, { encoding: encoding }]

      program_accounts = solana_client_request(
        p.payload[:config_urls],
        :get_program_accounts,
        params: params
      )

      Pipeline.new(200, p.payload.merge(program_accounts: program_accounts))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from program_accounts', e)
    end
  end

  # Search for the duplicated configs or config where signer is false
  def find_invalid_configs
    lambda do |p|
      return p unless p[:code] == 200

      info_pubkey = 'Va1idator1nfo111111111111111111111111111111'
      data = {}

      p.payload[:program_accounts].map do |account|
        begin
          next unless account.is_a?(Hash)

          data[account['pubkey']] = account.dig('account', 'data', 'parsed', 'info', 'keys')
        rescue TypeError => e
          # Sometimes value of 'parsed' key is an Array
          # that contains base64 encoded strings with ie. Shakespeare's poem.
          # so we skip it.
          next if e.message == 'no implicit conversion of String into Integer'
        end
      end

      # Find false and duplicated signers.
      false_signers = {}
      duplicated_count = Hash.new { |hash, key| hash[key] = []}
      duplicated_configs = Hash.new

      data.each do |k, v|
        next unless v.present?

        # Find false signers.
        false_signers[k] = v[1] if v[1]['signer'] == false

        # Add config key to array of keys for validator's pubkey.
        validator_key = v[1]['pubkey']
        duplicated_count[validator_key] << k

        # If validator has more than one config pubkey
        # add to duplicated_configs hash.
        if duplicated_count[validator_key].size > 1
          duplicated_configs[k] = duplicated_count[validator_key]
        end
      end

      # NOTE: We add duplicated_configs to paylaod
      # but for now entries we found are identical
      # so we do nothing with them.

      Pipeline.new(
        200,
        p.payload.merge(
          false_signers: false_signers,
          duplicated_configs: duplicated_configs
        )
      )
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from find_invalid_configs', e)
    end
  end

  # Removes invalid configs from array
  def remove_invalid_configs
    lambda do |p|
      return p unless p[:code] == 200

      false_signers_keys = p.payload[:false_signers].keys
      if false_signers_keys.any?
        p.payload[:validators_info].delete_if do |info|
          info['infoPubkey'].in?(false_signers_keys)
        end
      end
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from remove_invalid_configs', e)
    end
  end

  # vote_accounts_get returns the data from RPC 'getVoteAccounts'
  def vote_accounts_get
    lambda do |p|
      return p unless p[:code] == 200

      vote_accounts_json = solana_client_request(
        p.payload[:config_urls],
        :get_vote_accounts
      )['current']

      vote_accounts = {}

      # epochCredits History of how many credits earned by the end of each
      # epoch, as an array of arrays containing: [epoch, credits,
      # previousCredits]
      vote_accounts_json.each do |hash|
        credits_total = hash['epochCredits'][-1][1].to_i rescue 0
        credits_previous = hash['epochCredits'][-1][2].to_i rescue 0
        credits_current = credits_total - credits_previous
        vote_accounts[hash['nodePubkey']] = {
          'vote_account' => hash['votePubkey'],
          'activated_stake' => hash['activatedStake'],
          'commission' => hash['commission'],
          'last_vote' => hash['lastVote'],
          'credits' => credits_total,
          'credits_current' => credits_current
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
      rpc_servers = {}
      p.payload[:validators].each do |k, _v|
        unless p.payload[:vote_accounts][k].nil?
          validators_reduced[k] = \
            p.payload[:validators][k].merge(p.payload[:vote_accounts][k])
        end
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
        validator.set_active_vote_account(vote_account)

        # Create Vote records to save a time series of vote & stake data
        vote_account.vote_account_histories.create(
          network: p.payload[:network],
          batch_uuid: p.payload[:batch_uuid],
          commission: v['commission'],
          last_vote: v['last_vote'],
          credits: v['credits'],
          credits_current: v['credits_current'],
          slot_index_current: p.payload[:epoch_slot_index],
          activated_stake: v['activated_stake'],
          software_version: v['version'],
          software_client: v['client']
        )

        # Find or create the validator IP address
        val_ip = validator.validator_ips.find_or_create_by(
          version: 4,
          address: v['gossip_ip_port'].split(':')[0]
        )
        val_ip.set_is_active
        val_ip.touch
      end

      Pipeline.new(200, p.payload)
    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from validators_save', e)
    end
  end

  def validator_block_history_get
    lambda do |p|
      return p unless p[:code] == 200
      cli_method = "block-production --epoch #{p.payload[:epoch].to_i}"
      block_history = cli_request(cli_method, p.payload[:config_urls])

      raise 'No data from block-production' if block_history.blank? && block_history.is_a?(Hash)

      # Data for the validator_block_history_stats table
      block_history_stats = {
        'batch_uuid' => p.payload[:batch_uuid],
        'epoch' => p.payload[:epoch].to_i,
        'start_slot' => (block_history['start_slot'].to_i),
        'end_slot' => block_history['end_slot'].to_i,
        'total_slots' => block_history['total_slots'].to_i,
        'total_blocks_produced' => \
          block_history['total_blocks_produced'].to_i,
        'total_slots_skipped' => \
          block_history['total_slots_skipped'].to_i
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
          "skipped_slots_after" => 0,
          "skipped_slots_after_percent" => 0.0
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
            block_history["individual_slot_status"][i..i + 3].count do |s|
              s["skipped"] == true
            end

          if prior_leader.nil?
            i += 1
            next
          end

          validator_block_history[prior_leader]["skipped_slots_after"] += \
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
    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(
        500,
        p.payload,
        'Error from validator_block_history_save',
        e
      )
    end
  end

  def validators_info_get
    lambda do |p|
      return p unless p[:code] == 200

      results = cli_request('validator-info get', p.payload[:config_urls])

      Pipeline.new(200, p.payload.merge(validators_info: results))
    rescue StandardError => e
      Pipeline.new(
        500,
        p.payload,
        "Error from validators_info_get on #{p.payload[:network]}",
        e
      )
    end
  end

  def validators_info_save
    lambda do |p|
      return p unless p[:code] == 200

      p.payload[:validators_info].each do |result|
        validator = Validator.find_by(
          network: p.payload[:network],
          account: result['identityPubkey']
        )
        next unless validator

        utf_8_name = result['info']['name'].to_s.encode_utf_8.strip
        validator.name = utf_8_name unless utf_8_name.to_s.downcase.include?('script')

        keybase_name = result['info']['keybaseUsername'].to_s.strip
        validator.keybase_id = keybase_name unless keybase_name.to_s.downcase.include?('script')

        avatar_url = result['info']['iconUrl'].to_s.strip
        if avatar_url.present? && url_valid?(avatar_url)
          validator.avatar_url = avatar_url
        end

        www_url = result['info']['website'].to_s.strip
        if www_url && url_valid?(www_url)
          validator.www_url = www_url
        end

        utf_8_details = result['info']['details'].to_s.encode_utf_8.strip[0..254]
        validator.details = utf_8_details unless utf_8_details.to_s.downcase.include?('script')

        validator.info_pub_key = result['infoPubkey'].strip

        validator.save!
      rescue ActiveRecord::ConnectionNotEstablished => e
        Appsignal.send_error(e)
        puts "#{e.class}\n#{e.message}"
        exit(500)
      rescue StandardError => e
        # I don't want to break the loop, but I do want to write these to the
        # Rails log so I can see failures.
        Appsignal.send_error(e)
        Rails.logger.error "validator-info MESSAGE: #{e.message} CLASS: #{e.class}. Validator: #{result.inspect}"
      end
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(
        500,
        p.payload,
        "Error from validators_info_save on #{p.payload[:network]}",
        e
      )
    end
  end

  # Checks if the epoch has not changed during pipeline runtime.
  def check_epoch
    lambda do |p|
      return p unless p[:code] == 200

      epoch_json = solana_client_request(
        p.payload[:config_urls],
        :get_epoch_info
      )

      unless p.payload[:epoch] == epoch_json['epoch']
        Batch.where(uuid: p.payload[:batch_uuid]).destroy_all
        EpochHistory.where(batch_uuid: p.payload[:batch_uuid]).destroy_all
        ValidatorHistory.where(batch_uuid: p.payload[:batch_uuid]).destroy_all
        VoteAccountHistory.where(batch_uuid: p.payload[:batch_uuid]).destroy_all
        ValidatorBlockHistoryStat.where(batch_uuid: p.payload[:batch_uuid]).destroy_all
        ValidatorBlockHistory.where(batch_uuid: p.payload[:batch_uuid]).destroy_all

        Pipeline.new(500, p.payload, 'Epoch has changed since pipeline start (check_epoch).', e)
      end

      Pipeline.new(200, p.payload)
    rescue ActiveRecord::ConnectionNotEstablished => e
      Appsignal.send_error(e)
      puts "#{e.class}\n#{e.message}"
      exit(500)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from check_epoch', e)
    end
  end

  private

  def existing_validators(validator_attrs, network)
    accounts = validator_attrs.map { |validator| validator["identityPubkey"] }
    db_validator_accounts = Validator.where(network: network, account: accounts)
                                     .map { |v| { v.account => v.id }}
                                     .inject({}, :merge)

    validator_attrs.map do |validator|
      if db_validator_accounts[validator["identityPubkey"]]
        validator["id"] = db_validator_accounts[validator["identityPubkey"]]
        validator
      end
    end.compact
  end

  def url_valid?(url)
    return false if url.to_s.downcase.include?('script')

    avatar_url = URI.parse(url)
    return false unless avatar_url.kind_of?(URI::HTTP) || avatar_url.kind_of?(URI::HTTPS)

    true
  rescue URI::InvalidURIError => e
    false
  end
end
