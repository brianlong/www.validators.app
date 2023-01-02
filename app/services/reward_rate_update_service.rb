# frozen_string_literal: true

class RewardRateUpdateService

  def initialize(network, account_rewards)
    @network = network
    @account_rewards = account_rewards
  end

  def call
    cluster_stat.update(total_rewards: total_rewards)
  end

  private

  attr_reader :network, :account_rewards

  def cluster_stat
    ClusterStat.find_or_create_by(network: network)
  end

  def epoch_range
    @epoch_range ||= 
      EpochWallClock.where(network: network)
                    .where("extract(year from created_at) = ?", Date.current.year)
                    .last(3)
                    .pluck(:epoch)
  end

  def total_rewards
    account_rewards.inject(0) do |sum, (account, val)|
      sum + val["amount"] if epoch_range.include?(val["epoch"])
    end
  end
end
