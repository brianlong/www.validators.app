# frozen_string_literal: true

require "test_helper"

class PingThingRecentStatTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  test "doesn't create record with invalid interval" do
    stat = build(:ping_thing_recent_stat, interval: 12)

    refute stat.valid?
    assert_equal "Interval is not included in the list", stat.errors.full_messages.first

    stat.interval = ""
    refute stat.valid?
    assert_equal "Interval can't be blank", stat.errors.full_messages.first

    stat.interval = 5
    assert stat.valid?
  end

  test "doesn't create record with invalid network" do
    stat = build(:ping_thing_recent_stat, network: "fake")

    refute stat.valid?
    assert_equal "Network is not included in the list", stat.errors.full_messages.first

    stat.network = ""
    refute stat.valid?
    assert_equal "Network can't be blank", stat.errors.full_messages.first

    stat.network = "testnet"
    assert stat.valid?
  end

  test "#recalculate_stats updates ping_thing_recent_stat with correct values" do
    [1000, 2000, 3000, 4000, 5000].each do |time|
      create(:ping_thing, :testnet, reported_at: rand(4.minutes.ago..Time.now), response_time: time)
    end
    ping_stat = create(:ping_thing_recent_stat, interval: 5)

    ping_stat.recalculate_stats
    ping_stat.reload

    assert_equal 1000, ping_stat.min
    assert_equal 3000, ping_stat.median
    assert_equal 5000, ping_stat.p90
    assert_equal 5000, ping_stat.max
    assert_equal 5, ping_stat.num_of_records
  end

  test "#recalculate_stats does not include records created before selected interval" do
    [1000, 2000, 3000].each do |time|
      create(:ping_thing, :testnet, reported_at: rand(50.minutes.ago..Time.now), response_time: time)
    end
    create(:ping_thing, :testnet, reported_at: 62.minutes.ago, response_time: 5000)
    ping_stat = create(:ping_thing_recent_stat, interval: 60)

    ping_stat.recalculate_stats
    ping_stat.reload

    assert_equal 3000, ping_stat.max
    assert_equal 1000, ping_stat.min
    assert_equal 2000, ping_stat.median
    assert_equal 3, ping_stat.num_of_records
  end

  test "#to_builder returns required attributtes" do
    ping_stat = create(:ping_thing_recent_stat)
    required_keys = PingThingRecentStat::FIELDS_FOR_API.map(&:to_s)

    assert_equal required_keys, ping_stat.to_builder.attributes!.keys
  end

  test "creating new record broadcasts message" do
    skip
    # TODO
  end

  test "#recalculate_stats counts slot latency stats" do
    [9,3,2,1,3,4].each do |latency|
      create(
        :ping_thing,
        :testnet,
        reported_at: rand(50.minutes.ago..Time.now),
        slot_sent: 1,
        slot_landed: 1 + latency
      )
    end

    ping_stat = create(:ping_thing_recent_stat, interval: 60)

    ping_stat.recalculate_stats
    ping_stat.reload

    assert_equal 1, ping_stat.min_slot_latency
    assert_equal 3, ping_stat.average_slot_latency
    assert_equal 4, ping_stat.p90_slot_latency
  end

  test "#recalculate_stats counts fails count" do
    6.times do |time|
      create(
        :ping_thing,
        :testnet,
        reported_at: rand(50.minutes.ago..Time.now),
        success: time.even?
      )
    end

    ping_stat = create(:ping_thing_recent_stat, interval: 60)

    ping_stat.recalculate_stats
    ping_stat.reload

    assert_equal 3, ping_stat.fails_count
  end
end
