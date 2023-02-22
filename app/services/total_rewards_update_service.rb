# frozen_string_literal: true

class TotalRewardsUpdateService
  include SolanaRequestsLogic

  def initialize(network, stake_accounts, solana_url = nil)
    @network = network
    @stake_accounts = stake_accounts
    puts @stake_accounts.count
    @solana_url = solana_url ? [solana_url] : NETWORK_URLS[@network]
  end

  def call
    rewards_logger.warn("found epoch: #{completed_epoch&.epoch}") unless Rails.env.test?
    if completed_epoch
      vote_rewards = total_rewards_from_vote_accounts(completed_epoch)
      puts vote_rewards
      stake_rewards = total_rewards_from_stake_accounts(completed_epoch)
      puts stake_rewards
      if vote_rewards > 0 && stake_rewards > 0
        completed_epoch.update(
          total_rewards: vote_rewards + stake_rewards,
          total_active_stake: cluster_stat.total_active_stake
        )
      end
    end
  end

  def total_rewards_from_vote_accounts(epoch)
    rewards_sum = 0
    vote_accounts = VoteAccount.where(network: @network).pluck(:account)
    puts vote_accounts.count
    vote_accounts&.in_groups_of(1000) do |vote_account_batch|
      epoch_rewards(epoch.epoch, vote_account_batch.compact).each_with_index do |acc, index|
        if acc && acc["amount"] && acc["postBalance"]    
          rewards_sum += acc["amount"].to_i 
        end
      end
    end
    rewards_sum
  end

  def total_rewards_from_stake_accounts(epoch)
    rewards_sum = 0
    @stake_accounts&.in_groups_of(1000) do |stake_account_batch|
      epoch_rewards(epoch.epoch, stake_account_batch.compact).each_with_index do |acc, index|
        if acc && acc["amount"] && acc["postBalance"]    
          rewards_sum += acc["amount"].to_i 
        end
      end
    end
    rewards_sum
  end

  private

  def cluster_stat
    @cluster_stat ||= ClusterStat.find_or_create_by(network: @network)
  end

  def completed_epoch
    @completed_epoch ||= EpochWallClock.where(network: @network)
                                       .offset(1)
                                       .last
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
    log_path = File.join(Rails.root, "log", Rails.env)
    log_file_name = "total_rewards_update_service.log"
    log_file_path = File.join(log_path, log_file_name)
  
    FileUtils.mkdir_p(log_path)
  
    @rewards_logger ||= Logger.new(log_file_path)
  end
end
