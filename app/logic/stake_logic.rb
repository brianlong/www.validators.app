# frozen_string_literal: true

module StakeLogic
  include PipelineLogic
  include SolanaRequestsLogic
  include ApyHelper

  class NoResultsFromSolana < StandardError; end

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

      raise NoResultsFromSolana.new('No results from `solana stakes`') if stake_accounts.blank?

      reduced_stake_accounts = []

      StakePool.where(network: p.payload[:network]).each do |pool|
        pool_stake_acc = stake_accounts.select do |sa|
          sa["withdrawer"] == pool.authority || sa["staker"] == pool.authority
        end

        reduced_stake_accounts = reduced_stake_accounts + pool_stake_acc
      end

      Pipeline.new(200, p.payload.merge(
        stake_accounts: reduced_stake_accounts,
        all_stake_accounts: stake_accounts - reduced_stake_accounts,
        stake_accounts_active: stake_accounts_active(p.payload[:network], stake_accounts)
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
        vote_account = VoteAccount.where(
          network: p.payload[:network],
          account: acc['delegatedVoteAccountAddress']
        ).order(is_active: :desc).first

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

  def update_stake_pools
    lambda do |p|
      return p unless p.code == 200

      p.payload[:stake_pools].each do |pool|
        StakePools::CalculateAverageStats.new(pool).call
      end

      StakePool.transaction do
        p.payload[:stake_pools].each(&:save)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from update_stake_pools", e)
    end
  end

  def get_rewards_from_stake_pools
    lambda do |p|
      return p unless p.code == 200

      stake_accounts = StakeAccount.where(network: p.payload[:network])
      account_rewards = {}

      stake_accounts.each do |sa|
        account_rewards[sa.stake_pubkey] = nil
      end

      reward_info = solana_client_request(
        p.payload[:config_urls],
        "get_inflation_reward",
        params: [account_rewards.keys, {}]
      )

      raise NoResultsFromSolana.new("No results from `get_inflation_reward`") \
        if reward_info.blank?

      stake_accounts.each_with_index do |sa, idx|
        account_rewards[sa["stake_pubkey"]] = reward_info[idx]
      end

      # Sample account_rewards structure: 
      # { "account_id"=>{
      #   "amount"=>358573846,
      #   "commission"=>8,
      #   "effectiveSlot"=>169776008,
      #   "epoch"=>392,
      #   "postBalance"=>777282463666
      # }}
      Pipeline.new(200, p.payload.merge!(account_rewards: account_rewards))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from get_rewards_from_stake_pools", e)
    end
  end

  def assign_epochs
    lambda do |p|
      return p unless p.code == 200
      current_epoch, previous_epoch = set_epochs(p.payload[:network])

      Pipeline.new(200, p.payload.merge!(
        previous_epoch: previous_epoch,
        current_epoch: current_epoch
      ))
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from assign_epochs", e)
    end
  end

  def calculate_apy_for_accounts
    lambda do |p|
      return p unless p.code == 200

      num_of_epochs = number_of_epochs_in_year(p.payload[:network])

      StakeAccount.where(network: p.payload[:network]).each do |acc|
        apy = nil
        if p.payload[:account_rewards][acc.stake_pubkey]
          rewards = p.payload[:account_rewards][acc.stake_pubkey].symbolize_keys
          credits_diff = reward_with_fee(acc.stake_pool&.manager_fee, rewards[:amount])
          apy = calculate_apy(credits_diff, rewards, num_of_epochs)
        end
        acc.update(apy: apy)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from calculate_apy_for_accounts", e)
    end
  end

  def calculate_apy_for_pools
    lambda do |p|
      return p unless p.code == 200
      p.payload[:stake_pools].each do |pool|

        # select single history for each pubkey from the previous epoch
        history_accounts = StakeAccountHistory.select(
          "DISTINCT(stake_pubkey) stake_pubkey, active_stake"
        ).where(
          stake_pool: pool,
          epoch: p.payload[:previous_epoch].epoch
        )

        # total stake of all accounts in the pool
        total_stake = 0

        # sum of apy * stake
        weighted_apy_sum = pool.stake_accounts.inject(0) do |sum, sa|
          stake = history_accounts.select{ |h| h&.stake_pubkey == sa.stake_pubkey }.first&.active_stake
          # we don't want to include accounts with no stake
          if stake && stake > 0 
            total_stake += stake
            if sa.apy
              sum = sum + sa.apy * stake
            end
          end
          sum
        end

        if total_stake > 0
          average_apy = weighted_apy_sum / total_stake.to_f
          pool.update(average_apy: average_apy)
        end
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, "Error from calculate_apy_for_pools", e)
    end
  end

  private

  def recent_epochs(network)
    @recent_epochs ||= EpochWallClock.recent_finished(network).pluck(:epoch)
  end

  def stake_accounts_active(network, stake_accounts)
    active_stake_accounts = stake_accounts.select do |account|
      account["deactivationEpoch"].nil? ||
        recent_epochs(network).include?(account["deactivationEpoch"])
    end

    active_stake_accounts.map { |account| account["stakePubkey"] }
  end
end
