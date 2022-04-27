# frozen_string_literal: true

require "test_helper"

class CreatePingThingStatsServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"
    @pts_Service = CreatePingThingStatsService.new(network: @network)
    usr = create(:user)

    25.times do |n|
      create(
        :ping_thing,
        network: @network,
        user: usr,
        reported_at: DateTime.now - (n.minutes + 5.seconds)
      )
    end
  end

  test "should_add_new_stats returns false when current ping stats found" do
    PingThingStat::INTERVALS.each do |n|
      create(:ping_thing_stat, interval: n)
      refute @pts_Service.should_add_new_stats?(n)
    end
  end

  test "should_add_new_stats returns true when no current ping stats found" do
    PingThingStat::INTERVALS.each do |n|
      create(:ping_thing_stat, interval: n, time_from: DateTime.now - (n * 2 + 1).minutes)
      assert @pts_Service.should_add_new_stats?(n)
    end
  end

  test "gather_ping_things gathers correct records" do
    PingThingStat::INTERVALS.each do |n|
      pt = @pts_Service.gather_ping_things(n)
      assert_equal n, pt.count
      assert pt.last.reported_at > DateTime.now - n.minutes
    end
  end

  test "CreatePingThingStatsService creates correct records" do
    begin_minutes_ago = 24
    begin_minutes_ago.times.each do |n|
      CreatePingThingStatsService.new(time_to: (begin_minutes_ago - n).minutes.ago, network: @network).call
    end
    
    assert_equal 24, PingThingStat.where(interval: PingThingStat::INTERVALS[0]).count
    assert_equal 8, PingThingStat.where(interval: PingThingStat::INTERVALS[1]).count
    assert_equal 2, PingThingStat.where(interval: PingThingStat::INTERVALS[2]).count
    assert_equal 1, PingThingStat.where(interval: PingThingStat::INTERVALS[3]).count
  end
end
