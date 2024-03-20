#frozen_string_literal: true

require "test_helper"

class PingThingUserStatsServiceTest < ActiveSupport::TestCase

  setup do
    @user = create(:user)
    @network = "testnet"

    @ping_things = create_list(:ping_thing, 10, user_id: @user.id, network: @network)
  end

  test "#gather_ping_things grabs correct records" do
    create(:ping_thing, user_id: @user.id, network: "mainnet")
    create(:ping_thing, user_id: @user.id, network: "testnet", reported_at: 6.minutes.ago)

    service = PingThingUserStatsService.new(
      network: @network,
      interval: 5
    )

    ping_things = service.gather_ping_things

    assert_equal @ping_things, ping_things
  end

  test "#call saves correct records" do
    PingThingUserStatsService.new(network: @network, interval: 5).call

    assert_equal 1, PingThingUserStat.count
    assert_equal @user.id, PingThingUserStat.last.user_id
    assert_equal @network, PingThingUserStat.last.network
    assert_equal @user.username, PingThingUserStat.last.username
    assert_equal 10, PingThingUserStat.last.num_of_records
  end

  test "#call calculated correct stats" do
    @ping_things.second.update(slot_landed: 123, response_time: 10)
    @ping_things.last(4).each { |pt| pt.update slot_landed: 126, response_time: 3 }

    PingThingUserStatsService.new(network: @network, interval: 5).call

    assert_equal 10, PingThingUserStat.last.num_of_records
    assert_equal 1, PingThingUserStat.last.min
    assert_equal 3, PingThingUserStat.last.median
    assert_equal 3, PingThingUserStat.last.p90
    assert_equal 0, PingThingUserStat.last.min_slot_latency
    assert_equal 2, PingThingUserStat.last.average_slot_latency
    assert_equal 3, PingThingUserStat.last.p90_slot_latency
  end

  test "#call omits incorrect latencies" do
    @ping_things.first.update(slot_landed: 120) # incorrect latency - slot_landed smaller than slot_sent
    @ping_things.third.update(slot_landed: nil) # incorrect slot_landed
    @ping_things.second.update(slot_landed: 124) # correct latency 1

    PingThingUserStatsService.new(network: @network, interval: 5).call

    assert_equal 1, PingThingUserStat.last.min_slot_latency
    assert_equal 2, PingThingUserStat.last.average_slot_latency
    assert_equal 2, PingThingUserStat.last.p90_slot_latency
  end
end
