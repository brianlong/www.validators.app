# frozen_string_literal: true

class TrackCommissionChangesService
  include SolanaRequestsLogic

  def initialize(current_batch:, network: "mainnet", solana_url: nil)
    @current_batch = current_batch
    @previous_batch = Batch.where("created_at < ?", @current_batch.created_at)
                           .where(network: network)
                           .where.not(scored_at: nil)
                           .last
    @network = network
    @solana_url = solana_url || NETWORK_URLS[@network]
  end

  def call
    commission_history_logger.warn("tracking commission changes started at #{DateTime.now}")
    commission_history_logger.warn("current_batch #{@current_batch.uuid}, created at: #{@current_batch.created_at}")
    commission_history_logger.warn("previous_batch #{@previous_batch.uuid}, created at: #{@previous_batch.created_at}")

    VoteAccount.joins(:validator)
               .includes(validator: :validator_score_v1)
               .where(network: @network, is_active: true)
               .where("validators.is_active = TRUE")
               .in_batches(of: 100) do |va_batch|
      accounts = va_batch.pluck(:account)
      result = get_inflation_rewards(accounts)

      va_batch.each_with_index do |va, idx|  
        next unless result[idx] # some accounts have no inflation reward e. g. if it was inactive
  
        # check if commission from db matches commission from get_inflation_reward
        if va.validator.commission != result[idx]["commission"].to_f
          create_commission_for_previous_epoch(va, result[idx])
          create_commission_for_current_epoch(va, result[idx])
        end
      end
  
      sleep(2)
    end
  end

  def create_commission_for_current_epoch(va, cli_rewards)
    validator_commission = va.validator.commission

    first_commission_from_epoch = va.validator.commission_histories.where(
      epoch: cli_rewards["epoch"] + 1,
      network: @network,
    ).first

    unless first_commission_from_epoch && \
           first_commission_from_epoch.commission_before == cli_rewards["commission"].to_f && \
           first_commission_from_epoch.commission_after == validator_commission

      new_commission_history = va.validator.commission_histories.create(
        epoch: cli_rewards["epoch"] + 1,
        commission_before: cli_rewards["commission"].to_f,
        network: @network,
        commission_after: validator_commission,
        epoch_completion: 0.05,
        batch_uuid: @current_batch.uuid,
        from_inflation_rewards: true,
        created_at: @current_batch.created_at
      )
      commission_history_logger.warn(
        "created_commission_history: \
        epoch: #{new_commission_history.epoch}, \
        val: #{va.validator.account}, \
        created: #{new_commission_history.created_at}"
      )
    end
  end

  def create_commission_for_previous_epoch(va, cli_rewards)
    validator_commission = va.validator.commission

    last_commission_from_epoch = va.validator.commission_histories.where(
      epoch: cli_rewards["epoch"],
      network: @network,
    ).last

    unless last_commission_from_epoch && \
           last_commission_from_epoch.commission_before == validator_commission && \
           last_commission_from_epoch.commission_after == cli_rewards["commission"].to_f

      new_commission_history = va.validator.commission_histories.create(
        epoch: cli_rewards["epoch"],
        commission_after: cli_rewards["commission"].to_f,
        network: @network,
        commission_before: validator_commission,
        epoch_completion: 99.95,
        batch_uuid: @previous_batch.uuid,
        from_inflation_rewards: true,
        created_at: @previous_batch.created_at
      )

      commission_history_logger.warn(
        "created_commission_history: \
        epoch: #{new_commission_history.epoch}, \
        val: #{va.validator.account}, \
        created: #{new_commission_history.created_at}"
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

  def commission_history_logger
    log_path = File.join(Rails.root, 'log', Rails.env)
    log_file_name = 'commission_history_tracker.log'
    log_file_path = File.join(log_path, log_file_name)
  
    FileUtils.mkdir_p(log_path)
  
    @commission_history_logger ||= Logger.new(log_file_path)
  end
end
