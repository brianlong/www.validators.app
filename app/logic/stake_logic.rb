# frozen_string_literal: true

module StakeLogic
  include PipelineLogic
  include SolanaLogic #for solana_client_request

  def get_last_batch
    lambda do |p|
      return p unless p.code == 200

      last_batch = Batch.last_scored(p.payload[:network])

      if last_batch.nil?
        raise "No batch: #{p.payload[:network]}, #{p.payload[:batch_uuid]}"
      end

      Pipeline.new(200, p.payload.merge(batch: last_batch))
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
      puts stake_accounts.count
      reduced_stake_accounts = []
      StakePool.where(network: p.payload[:network]).each do |pool|
        pool_stake_acc = stake_accounts.select{ |sa| sa['withdrawer'] == pool.authority }
        puts pool.name
        puts pool_stake_acc
        puts "---------------------"
        reduced_stake_accounts.push pool_stake_acc
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
        account_histories.push StakeAccountHistory.new(old_stake.attributes)
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

  def save_stake_accounts
    lambda do |p|
      return p unless p.code == 200

      p.payload[:stake_accounts].each do |acc|
        val = VoteAccount.find_by(
          network: p.payload[:network],
          account: acc['delegatedVoteAccountAddress']
        ).validator.id rescue nil

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
          validator_id: val
        )
      end

      StakeAccount.where.not(batch_uuid: p.payload[:batch].uuid).delete_all

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from save_stake_accounts', e)
    end
  end

  def assign_stake_pools
    lambda do |p|
      return p unless p.code == 200
      StakePool.where(network: p.payload[:network]).each do |pool|
        StakeAccount.where(withdrawer: pool.authority, network: p.payload[:network])
                    .update_all(stake_pool_id: pool.id)
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from assign_stake_pools', e)
    end
  end
end
