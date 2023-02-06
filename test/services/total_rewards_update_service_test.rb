# frozen_string_literal: true

require "test_helper"

class TotalRewardsUpdateServiceTest < ActiveSupport::TestCase
  include SolanaRequestsLogic

  def setup
    @network = "mainnet"
    @solana_url = "https://api.mainnet-beta.solana.com"
    @vote_acc = ["BFpfnLfnE4zY5TNvywbH1sPU9kCe1vo1pPF1QsMHU6gL", "BmZFrXp57Z8b4SDP6sn6pjMwKUzWt6WHT4qg943hGmwa"]
  end

  test "updating cluster stat with total rewards difference" do
    EpochWallClock.delete_all

    cluster_stat = create(:cluster_stat, network: @network)
    epoch = create(:epoch_wall_clock, epoch: 407, network: @network, starting_slot: 1, ending_slot: 2)

    VCR.use_cassette("get_inflation_reward") do
      TotalRewardsUpdateService.new(@network, @vote_acc, @solana_url).call

      epoch.reload

      assert_equal 29627766, epoch.total_rewards
    end
  end
end
