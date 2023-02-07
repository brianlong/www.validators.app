# frozen_string_literal: true

class TotalRewardsUpdateService
  include SolanaRequestsLogic

  def initialize(network, stake_accounts, solana_url = nil)
    @network = network
    @stake_accounts = stake_accounts
    @solana_url = solana_url ? [solana_url] : NETWORK_URLS[@network]
  end

  def call
    rewards_logger.warn("found epoch: #{completed_epoch&.epoch}") unless Rails.env.test?
    if completed_epoch
      rewards = total_rewards(completed_epoch)
      rewards_logger.warn("total_rewards: #{rewards}") unless Rails.env.test?
      if rewards > 0
        completed_epoch.update(total_rewards: rewards, total_active_stake: cluster_stat.total_active_stake)
      end
    end
  end

  private

  def cluster_stat
    @cluster_stat ||= ClusterStat.find_or_create_by(network: @network)
  end

  def completed_epoch
    @completed_epoch ||= EpochWallClock.where(network: @network)
                                       .where.not(ending_slot: nil)
                                       .last
  end

  def total_rewards(epoch)
    rewards_sum = 0
    rewards_logger.warn("stake_accounts count: #{@stake_accounts.count}") unless Rails.env.test?
    @stake_accounts&.in_groups_of(1000) do |stake_account_batch|
      epoch_rewards(epoch.epoch, stake_account_batch.compact).each do |acc|
        rewards_sum += acc["amount"].to_i if acc && acc["amount"]
      end
    end
    rewards_sum
  end

  def epoch_rewards(epoch, stake_accounts)
    solana_client_request(
      @solana_url,
      :get_inflation_reward,
      params: [
        stake_accounts,
        { epoch: epoch }
      ]
    )
  end

  def rewards_logger
    log_path = File.join(Rails.root, 'log', Rails.env)
    log_file_name = 'total_rewards_update_service.log'
    log_file_path = File.join(log_path, log_file_name)
  
    FileUtils.mkdir_p(log_path)
  
    @rewards_logger ||= Logger.new(log_file_path)
  end
end
