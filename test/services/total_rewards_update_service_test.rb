# frozen_string_literal: true

require "test_helper"

class TotalRewardsUpdateServiceTest < ActiveSupport::TestCase
  include SolanaRequestsLogic

  def setup
    @network = "mainnet"
    @solana_url = "https://api.mainnet-beta.solana.com"
    @stake_acc = ["BFpfnLfnE4zY5TNvywbH1sPU9kCe1vo1pPF1QsMHU6gL", "BmZFrXp57Z8b4SDP6sn6pjMwKUzWt6WHT4qg943hGmwa"]

    create(:vote_account, account: "9GJmEHGom9eWo4np4L5vC6b6ri1Df2xN8KFoWixvD1Bs", network: @network)
    create(:vote_account, account: "Gzof6d9Hm9b1g9TqrbqbVBSXAaf1GdxkhKRBmG9Da8y7", network: @network)
  end

  test "#total_rewards_from_stake_accounts returns correct result" do
    cluster_stat = create(:cluster_stat, network: @network)
    epoch = create(:epoch_wall_clock, epoch: 407, network: @network, starting_slot: 1, ending_slot: 2)

    VCR.use_cassette("total_rewards_from_stake_accounts") do
      result = TotalRewardsUpdateService.new(@network, @stake_acc, @solana_url).total_rewards_from_stake_accounts(epoch)

      assert_equal 29627766, result
    end
  end

  test "#total_rewards_from_vote_accounts returns correct result" do
    cluster_stat = create(:cluster_stat, network: @network)
    epoch = create(:epoch_wall_clock, epoch: 407, network: @network, starting_slot: 1, ending_slot: 2)

    VCR.use_cassette("total_rewards_from_vote_accounts") do
      result = TotalRewardsUpdateService.new(@network, @stake_acc, @solana_url).total_rewards_from_vote_accounts(epoch)

      assert_equal 77432940417, result
    end
  end
end
