require 'test_helper'

# StakeLogicTest
class ApyHelperTest < ActiveSupport::TestCase
  include StakeLogic::ApyHelper

  setup do
    @network = "testnet"
  end

  test "number_of_epochs returns correct number" do
    create(:cluster_stat, network: @network, epoch_duration: 159521.0)

    num_of_epochs = number_of_epochs(@network)

    assert_equal 197, num_of_epochs.to_i
  end

  test "set_epochs returns last two epochs" do
    2.times do |n|
      create(:epoch_wall_clock, network: @network, epoch: n + 1, created_at: n.days.ago)
    end

    current_epoch, previous_epoch = set_epochs(@network)

    assert_equal 2, current_epoch.epoch
    assert_equal 1, previous_epoch.epoch
  end

  test "reward_with_fee returns reward when there is no fee" do
    assert_equal 1000, reward_with_fee(nil, 1000)
  end

  test "reward_with_fee returns correct result when fee is provided" do
    assert_equal 900, reward_with_fee(10, 1000)
  end

  test "calculate_apy" do
    credits_diff = 1
    rewards = {
      postBalance: 1000,
      amount: 1
    }
    num_of_epochs = 1

    apy = calculate_apy(credits_diff, rewards, num_of_epochs)

    assert_equal 0.1001, apy
  end
end
