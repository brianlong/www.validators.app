# frozen_string_literal: true

class GatherExplorerStakeAccountsService
  include PipelineLogic
  include SolanaRequestsLogic

  BATCH_SIZE = 500

  def initialize(network: "mainnet", config_urls:, current_epoch: nil, demo: true, stake_accounts: [])
    @network = network
    @config_urls = config_urls
    @stake_accounts = stake_accounts
    @current_epoch = current_epoch || EpochWallClock.by_network(@network).first.epoch
    @demo = demo
    log_path = Rails.root.join("log", "#{self.class.name.demodulize.underscore}_#{@network}.log")
    @logger ||= Logger.new(log_path)
  end

  def call
    get_stake_accounts
    update_stake_accounts
  rescue StandardError => e
    @logger.error(e.message)
    @logger.error(e.backtrace.join("\n"))
  end

  private

  def get_stake_accounts
    @stake_accounts = cli_request(
      "stakes",
      @config_urls
    ) unless @stake_accounts.present?

    @logger.info("total results from solana stakes: #{@stake_accounts.count}}")
  end

  def update_stake_accounts
    batch_no = 0
    @stake_accounts.in_groups_of(BATCH_SIZE) do |batch|
      batch_no += 1
      updated_stake_accounts = []
      @logger.info("processing batch #{batch_no} of #{@stake_accounts.count / BATCH_SIZE.to_f}.ceil")

      batch.compact.each do |acc|
        esa = ExplorerStakeAccount.find_or_initialize_by(
          stake_pubkey: acc["stakePubkey"],
          network: @network
        )

        esa.assign_attributes(
          account_balance: acc["accountBalance"],
          activation_epoch: acc["activationEpoch"],
          active_stake: acc["activeStake"],
          credits_observed: acc["creditsObserved"],
          deactivating_stake: acc["deactivatingStake"],
          deactivation_epoch: acc["deactivationEpoch"],
          delegated_stake: acc["delegatedStake"],
          delegated_vote_account_address: acc["delegatedVoteAccountAddress"],
          rent_exempt_reserve: acc["rentExemptReserve"],
          stake_pubkey: acc["stakePubkey"],
          stake_type: acc["stakeType"],
          staker: acc["staker"],
          withdrawer: acc["withdrawer"],
          epoch: @current_epoch
        )

        updated_stake_accounts << esa
      end
      save_stake_accounts(updated_stake_accounts)
    end
  end

  def save_stake_accounts(esa_batch)
    unless @demo
      esa_batch.each(&:save!)
      @logger.info("saved #{esa_batch.count} stake accounts")
    end
  end
end
