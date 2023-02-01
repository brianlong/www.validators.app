# frozen_string_literal: true

class TotalRewardsUpdateService
  include SolanaRequestsLogic

  def initialize(network, stake_accounts)
    @network = network
    @stake_accounts = stake_accounts
  end

  def call
    if completed_epoch
      rewards = total_rewards(completed_epoch)
      completed_epoch.update(total_rewards: rewards, total_active_stake: cluster_stat.total_active_stake)
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
    epoch_rewards(epoch).compact.inject(0) do |sum, val|
      next unless val["amount"]

      sum + val["amount"].to_i
    end
  end

  def epoch_rewards(epoch)
    solana_client_request(
      NETWORK_URLS[@network],
      :get_inflation_reward,
      params: [
        @stake_accounts,
        { epoch: epoch }
      ]
    )
  end
end
