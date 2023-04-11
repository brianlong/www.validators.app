# frozen_string_literal: true

require "test_helper"

class RecalculatePingThingStatsServiceTest  < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  test "#call updates appropriate stats" do
    network = "testnet"
    stat = create(
      :ping_thing_stat,
      network: network,
      interval: 3,
      min: 1,
      max: 1,
      median: 1,
      num_of_records: 0,
      time_from: 4.minutes.ago
    )

    pt = create(
      :ping_thing,
      amount: "1",
      response_time: "2",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      network: network,
      user_id: @user.id,
      reported_at: 3.minutes.ago
    )

    RecalculatePingThingStatsService.new(reported_at: 3.minutes.ago, network: network).call

    stat.reload

    assert_equal 2, stat.max
    assert_equal 2, stat.min
    assert_equal 2, stat.median
    assert_equal 1, stat.num_of_records
  end

  test "#call does not update older stats" do
    network = "testnet"
    stat = create(
      :ping_thing_stat,
      network: network,
      interval: 3,
      min: 1,
      max: 1,
      median: 1,
      num_of_records: 0,
      time_from: 10.minutes.ago
    )

    pt = create(
      :ping_thing,
      amount: "1",
      response_time: "2",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer",
      network: network,
      user_id: @user.id,
      reported_at: 3.minutes.ago
    )

    assert_no_changes("stat.attributes") do
      RecalculatePingThingStatsService.new(reported_at: 3.minutes.ago, network: network).call
    end
  end
end
