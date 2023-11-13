# frozen_string_literal: true

require "test_helper"

class CreatePingThingStatsServiceTest < ActiveSupport::TestCase
  setup do
    @network = "testnet"
    @pts_Service = CreatePingThingStatsService.new(network: @network)
    @usr = create(:user)

    170.times do |n|
      create(
        :ping_thing,
        network: @network,
        user: @usr,
        response_time: n,
        reported_at: DateTime.now - (n.minutes + 5.seconds),
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
      serv = CreatePingThingStatsService.new(time_to: (begin_minutes_ago - n).minutes.ago, network: @network)
      serv.stub(:get_transactions_count, n * 100) do
        serv.call
      end
    end
    
    assert_equal 24, PingThingStat.where(interval: PingThingStat::INTERVALS[0]).count
    assert_equal 8, PingThingStat.where(interval: PingThingStat::INTERVALS[1]).count
    assert_equal 2, PingThingStat.where(interval: PingThingStat::INTERVALS[2]).count
    assert_equal 1, PingThingStat.where(interval: PingThingStat::INTERVALS[3]).count
    assert_equal 2_300, PingThingStat.where(interval: PingThingStat::INTERVALS[0]).last.transactions_count
    assert_equal 2_100, PingThingStat.where(interval: PingThingStat::INTERVALS[1]).last.transactions_count
    assert_equal 1_200, PingThingStat.where(interval: PingThingStat::INTERVALS[2]).last.transactions_count
    assert PingThingStat.where(interval: PingThingStat::INTERVALS[0]).last.tps.positive?
  end

  test "CreatePingThingStatsService does not return error when slot fields are empty" do
    PingThing.update_all(slot_sent: nil, slot_landed: nil)
    
    assert_nothing_raised do
      serv = CreatePingThingStatsService.new(time_to: 1.minutes.ago, network: @network)
      serv.stub(:get_transactions_count, 100) do
        serv.call
      end
    end
  end

  test "CreatePingThingStatsService creates records with correct fields" do
    begin_minutes_ago = 1
    begin_minutes_ago.times.each do |n|
      serv = CreatePingThingStatsService.new(time_to: (begin_minutes_ago - n).minutes.ago, network: @network)
      serv.stub(:get_transactions_count, n * 100) do
        serv.call
      end
    end
    
    stat = PingThingStat.where(interval: PingThingStat::INTERVALS[3]).last
    assert_equal 24, stat.interval
    assert_equal 1, stat.min
    assert_equal 24, stat.max
    assert_equal 13, stat.median
    assert_equal 24, stat.num_of_records
    assert_equal @network, stat.network
    assert_equal 2, stat.average_slot_latency
  end

  test "CreatePingThingStatsService calculates real average of slot_latency" do
    slot_latency = 4

    25.times do |n|
      create(
        :ping_thing,
        network: "mainnet",
        user: @usr,
        response_time: n,
        reported_at: DateTime.now - (n.minutes + 5.seconds),
        slot_sent: n,
        slot_landed: n + slot_latency
      )
    end

    begin_minutes_ago = 1
    begin_minutes_ago.times.each do |n|
      serv = CreatePingThingStatsService.new(time_to: (begin_minutes_ago - n).minutes.ago, network: "mainnet")
      serv.stub(:get_transactions_count, n * 100) do
        serv.call
      end
    end
    
    stat = PingThingStat.where(interval: PingThingStat::INTERVALS[3]).last
    assert_equal slot_latency, stat.average_slot_latency
  end
end
