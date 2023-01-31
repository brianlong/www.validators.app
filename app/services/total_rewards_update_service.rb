# frozen_string_literal: true

class TotalRewardsUpdateService
  include SolanaRequestsLogic

  def initialize(network, stake_accounts)
    @network = network
    @stake_accounts = stake_accounts
  end

  def call
    rewards_start_epoch = total_rewards(epoch_range.min)
    rewards_end_epoch = total_rewards(epoch_range.max)

    cluster_stat.update(
      total_rewards_difference: rewards_end_epoch - rewards_start_epoch
    ) if rewards_end_epoch && rewards_start_epoch
  end

  private

  attr_reader :network, :stake_accounts

  def cluster_stat
    @cluster_stat ||= ClusterStat.find_or_create_by(network: network)
  end

  def epoch_range
    @epoch_range ||= begin
      # Get three latest epochs
      # Current epoch is skipped by getInflationReward RPC method
      epochs = EpochWallClock.by_network(network).offset(1).limit(3).pluck(:epoch)

      OpenStruct.new(min: epochs.min, max: epochs.max)
    end
  end

  def total_rewards(epoch)
    solana_rewards(epoch).compact.inject(0) do |sum, val|
      next unless val["amount"]

      sum + val["amount"].to_i
    end
  end

  def solana_rewards(epoch)
    solana_client_request(
      NETWORK_URLS[network],
      :get_inflation_reward,
      params: [
        stake_accounts
      ]
    )
  rescue StandardError => e
    Pipeline.new(500, p.payload, 'Error from solana_rewards', e)
  end
end
