# frozen_string_literal: true

require "test_helper"

class TotalRewardsUpdateServiceTest < ActiveSupport::TestCase
  include SolanaRequestsLogic

  def setup
    @network = "mainnet"
  end

  test "updating cluster stat with total rewards difference" do
    cluster_stat = create(:cluster_stat, network: @network)
    create(:epoch_wall_clock, epoch: 397, network: @network)
    create(:epoch_wall_clock, epoch: 398, network: @network)
    create(:epoch_wall_clock, epoch: 399, network: @network)

    VCR.use_cassette("get_inflation_reward") do
      TotalRewardsUpdateService.new(@network, []).call

      cluster_stat.reload

      assert_equal 1604, cluster_stat.total_rewards_difference
    end
  end
end
