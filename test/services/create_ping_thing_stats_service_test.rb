# frozen_string_literal: true

require "test_helper"

class CreatePingThingStatsServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"
    @pts_Service = CreatePingThingStatsService.new(network: @network)
    usr = create(:user)

    60.times do |n|
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
    begin_minutes_ago = 60
    begin_minutes_ago.times.each do |n|
      CreatePingThingStatsService.new(time_to: (begin_minutes_ago - n).minutes.ago, network: @network).call
    end
    
    assert_equal 59, PingThingStat.where(interval: 1).count
    assert_equal 20, PingThingStat.where(interval: 3).count
    assert_equal 12, PingThingStat.where(interval: 5).count
    assert_equal 5, PingThingStat.where(interval: 12).count
    assert_equal 3, PingThingStat.where(interval: 24).count
    assert_equal 1, PingThingStat.where(interval: 60).count
  end

  test "CreatePingThingStatsService calculates correct stats" do
    PingThing.delete_all
    [1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000].each do |time|
      create(:ping_thing, :testnet, reported_at: rand(10.seconds.ago..Time.now), response_time: time)
    end

    [500, 14000, 15000].each do |time|
      create(:ping_thing, :testnet, reported_at: rand(4.minutes.ago..3.minutes.ago), response_time: time)
    end

    CreatePingThingStatsService.new(time_to: Time.now, network: @network).call

    pt1 = PingThingStat.where(interval: 1).last
    assert_equal 10, pt1.num_of_records
    assert_equal 1000, pt1.min
    assert_equal 10000, pt1.max
    assert_equal 9000, pt1.p90

    pt5 = PingThingStat.where(interval: 5).last
    assert_equal (10+3), pt5.num_of_records
    assert_equal 500, pt5.min
    assert_equal 15000, pt5.max
    assert_equal 10000, pt5.p90
  end
end
