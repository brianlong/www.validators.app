# frozen_string_literal: true

module StakeLogic
  include PipelineLogic
  include SolanaLogic #for solana_client_request

  def get_last_batch
    lambda do |p|
      return p unless p.code == 200

      batch = Batch.last_scored(p.payload[:network])

      if batch.nil?
        raise "No batch: #{p.payload[:network]}, #{p.payload[:batch_uuid]}"
      end

      Pipeline.new(200, p.payload.merge(batch: batch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from set_this_batch', e)
    end
  end

  def get_stake_accounts
    lambda do |p|
      return p unless p.code == 200

      stake_accounts = cli_request(
        'stakes',
        p.payload[:config_urls]
      )

      reduced_stake_accounts = []

      StakePool.where(network: p.payload[:network]).each do |pool|
        pool_stake_acc = stake_accounts.select do |sa| 
          sa["withdrawer"] == pool.authority || sa["staker"] == pool.authority
        end

        reduced_stake_accounts = reduced_stake_accounts + pool_stake_acc
      end

      Pipeline.new(200, p.payload.merge(
        stake_accounts: reduced_stake_accounts
      ))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from get_stake_accounts', e)
    end
  end

  def move_current_stakes_to_history
    lambda do |p|
      return p unless p.code == 200

      account_histories = []

      StakeAccount.where.not(
        batch_uuid: p.payload[:batch].uuid,
        network: p.payload[:network]
      ).each do |old_stake|
        account_histories.push StakeAccountHistory.new(old_stake.attributes.except("id"))
      end

      if account_histories.any?
        StakeAccountHistory.transaction do
          account_histories.each(&:save)
        end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from move_current_stakes_to_history', e)
    end
  end

  def update_stake_accounts
    lambda do |p|
      return p unless p.code == 200

      current_epoch = EpochWallClock.where(network: p.payload[:network])
                                    .order(created_at: :desc)
                                    .first
                                    .epoch

      p.payload[:stake_accounts].each do |acc|
        vote_account = VoteAccount.find_by(
          network: p.payload[:network],
          account: acc['delegatedVoteAccountAddress']
        )
        
        validator_id = vote_account ? vote_account.validator.id : nil

        StakeAccount.find_or_initialize_by(
          stake_pubkey: acc['stakePubkey'],
          network: p.payload[:network]
        ).update(
          account_balance: acc['accountBalance'],
          activation_epoch: acc['activationEpoch'],
          active_stake: acc['activeStake'],
          credits_observed: acc['creditsObserved'],
          deactivating_stake: acc['deactivatingStake'],
          deactivation_epoch: acc['deactivationEpoch'],
          delegated_stake: acc['delegatedStake'],
          delegated_vote_account_address: acc['delegatedVoteAccountAddress'],
          rent_exempt_reserve: acc['rentExemptReserve'],
          stake_pubkey: acc['stakePubkey'],
          stake_type: acc['stakeType'],
          staker: acc['staker'],
          withdrawer: acc['withdrawer'],
          batch_uuid: p.payload[:batch].uuid,
          validator_id: validator_id,
          epoch: current_epoch
        )
      end

      StakeAccount.where(network: p.payload[:network]).where.not(batch_uuid: p.payload[:batch].uuid).delete_all

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from save_stake_accounts', e)
    end
  end

  def assign_stake_pools
    lambda do |p|
      return p unless p.code == 200
      
      stake_pools = StakePool.where(network: p.payload[:network])

      stake_pools.each do |pool|
        StakeAccount.where(withdrawer: pool.authority, network: p.payload[:network])
                    .update_all(stake_pool_id: pool.id)
      end

      Pipeline.new(200, p.payload.merge(stake_pools: stake_pools))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from assign_stake_pools', e)
    end
  end

  def update_validator_stats
    lambda do |p|
      return p unless p.code == 200

      p.payload[:stake_pools].each do |pool|
        validator_ids = pool.stake_accounts.active.pluck(:validator_id)
        delinquent_count = 0
        last_skipped_slots = []
        uptimes = []
        lifetimes = []
        scores = []

        Validator.where(id: validator_ids).each do |validator|
          score = validator.score

          last_delinquent = validator.validator_histories
                                     .order(created_at: :desc)
                                     .where(delinquent: true)
                                     .first
                                     &.created_at || (DateTime.now - 30.days)

          uptime = (DateTime.now - last_delinquent.to_datetime).to_i
          lifetime = (DateTime.now - validator.created_at.to_datetime).to_i
          uptimes.push uptime
          lifetimes.push lifetime
          scores.push score.total_score.to_i
          delinquent_count = score.delinquent ? delinquent_count + 1 : delinquent_count
          last_skipped_slots.push score.skipped_slot_history&.last
        end

        pool.average_uptime = uptimes.average
        pool.average_lifetime = lifetimes.average
        pool.average_score = scores.average.round(2)
        pool.average_delinquent = (delinquent_count / validator_ids.size) * 100
        pool.average_skipped_slots = last_skipped_slots.compact.average
      end

      StakePool.transaction do
        p.payload[:stake_pools].each(&:save)
      end
      
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from update_validator_stats", e)
    end
  end

  def count_average_validators_commission
    lambda do |p|
      return p unless p.code == 200

      StakePool.where(network: p.payload[:network]).each do |pool|
        validator_ids = pool.stake_accounts.active.pluck(:validator_id)
        average_commission = ValidatorScoreV1.where(validator_id: validator_ids)
                                             .average(:commission)

        pool.update_attribute(:average_validators_commission, average_commission)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from count_average_validator_fee", e)
    end
  end

  def get_rewards
    lambda do |p|
      stake_accounts = StakeAccount.where(network: p.payload[:network])
      reward_info = solana_client_request(
        p.payload[:config_urls],
        "get_inflation_reward",
        params: [stake_accounts.pluck(:stake_pubkey)]
      )

      account_rewards = {}

      stake_accounts.each_with_index do |sa, idx|
        account_rewards[sa["stake_pubkey"]] = reward_info[idx]
      end
      Pipeline.new(200, p.payload.merge!(account_rewards: account_rewards))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from get_rewards", e)
    end
  end

  def calculate_apy_for_accounts
    lambda do |p|
      return p unless p.code == 200

      last_epoch = EpochWallClock.where(
        network: p.payload[:network]
      ).last

      previous_epoch = EpochWallClock.where(
        network: p.payload[:network],
        epoch: last_epoch.epoch - 1
      ).last

      num_of_epochs = 1.year.to_i / (last_epoch.created_at - previous_epoch.created_at).to_i.to_f

      StakeAccount.where(network: p.payload[:network]).each do |acc|
        previous_acc = StakeAccountHistory.where(
          stake_pubkey: acc.stake_pubkey,
          epoch: acc.epoch - 1
        ).first
        
        next unless p.payload[:account_rewards][acc.stake_pubkey]

        rewards = p.payload[:account_rewards][acc.stake_pubkey].symbolize_keys

        if fee = acc.stake_pool&.manager_fee || nil
          credits_diff = rewards[:amount] - rewards[:amount] * (fee / 100)
        else
          credits_diff = rewards[:amount]
        end

        next unless credits_diff > 0
        credits_diff_percent = credits_diff / (rewards[:postBalance] - rewards[:amount]).to_f

        apy = (((1 + credits_diff_percent) ** num_of_epochs) - 1) * 100
        apy = apy < 100 && apy > 0 ? apy.round(6) : nil
        acc.update(apy: apy)
      end
      puts last_epoch
      puts previous_epoch
      Pipeline.new(200, p.payload.merge!(previous_epoch: previous_epoch))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from calculate_apy_for_accounts", e)
    end
  end

  def calculate_apy_for_pools
    lambda do |p|
      p.payload[:stake_pools].each do |pool|
        history_accounts = StakeAccountHistory.where(
          stake_pool: pool,
          epoch: p.payload[:previous_epoch].epoch
        ).select("DISTINCT(stake_pubkey) stake_pubkey, active_stake")
        puts history_accounts.inspect
        total_stake = 0
        weighted_apy_sum = pool.stake_accounts.inject(0) do |sum, sa|
          stake = history_accounts.select{ |h| h&.stake_pubkey == sa.stake_pubkey }.first.active_stake
          if stake && stake > 0
            total_stake += stake
            if stake && stake > 0 && sa.apy
              sum + sa.apy * stake
            end
          end
        end
        puts "sum: #{weighted_apy_sum}"
        pool.update(average_apy: weighted_apy_sum / total_stake)
      end
      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from calculate_apy_for_pools", e)
    end
  end
end
