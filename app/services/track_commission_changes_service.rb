# frozen_string_literal: true

class TrackCommissionChangesService
  include SolanaRequestsLogic

  def initialize(current_batch: , network: "mainnet", solana_url: nil)
    @current_batch = current_batch
    @previous_batch = Batch.where("created_at < ?", @current_batch.created_at)
                           .where(network: network)
                           .where.not(scored_at: nil)
                           .last
    @network = network
    @solana_url = solana_url || NETWORK_URLS[@network]
  end

  def call
    VoteAccount.includes(:validator).where(network: @network).in_batches(of: 100) do |va_batch|
      accounts = va_batch.pluck(:account)
      result = get_inflation_rewards(accounts)

      va_batch.each_with_index do |va, idx|  
        next unless result[idx] # some accounts have no inflation reward e. g. if it was inactive
  
        # check if commission from db matches commission from get_inflation_reward
        if va.validator.commission != result[idx]["commission"].to_f
          check_commission_for_current_epoch(va, result[idx])
          check_commission_for_previous_epoch(va, result[idx])
        end
      end
  
      sleep(2)
    end
  end

  def create_commission_for_current_epoch(va, cli_rewards)
    validator_commission = va.validator.commission

    last_commission_from_epoch = va.validator.commission_histories.where(
      epoch: cli_rewards["epoch"] + 1,
      network: @network,
    ).last

    unless last_commission_from_epoch.commission_before == cli_rewards["commission"].to_f && \
           last_commission_from_epoch.commission_after == validator_commission

      va.validator.commission_histories.create(
        epoch: cli_rewards["epoch"] + 1,
        commission_before: cli_rewards["commission"].to_f,
        network: @network,
        commission_after: validator_commission,
        epoch_completion: 0.05,
        batch_uuid: @current_batch.uuid,
        from_inflation_rewards: true
      )
    end
  end

  def create_commission_for_previous_epoch(va, cli_rewards)
    validator_commission = va.validator.commission

    first_commission_from_epoch = va.validator.commission_histories.where(
      epoch: cli_rewards["epoch"],
      network: @network,
    ).first

    unless first_commission_from_epoch.commission_before == validator_commission && \
      last_commission_from_epoch.commission_after == cli_rewards["commission"].to_f

    va.validator.commission_histories.create(
      epoch: cli_rewards["epoch"],
      commission_after: cli_rewards["commission"].to_f,
      network: @network,
      commission_before: validator_commission,
      epoch_completion: 99.95,
      batch_uuid: @previous_batch.uuid,
      from_inflation_rewards: true
    )
    end
  end

  private 

  def get_inflation_rewards(accounts)
    solana_client_request(
      @solana_url,
      "get_inflation_reward",
      params: [accounts]
    )
  end
end