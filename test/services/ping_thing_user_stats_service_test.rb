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
    assert_equal @ping_things.pluck(:response_time).compact.sort.median, PingThingUserStat.last.median
    assert_equal @ping_things.pluck(:response_time).compact.sort.min, PingThingUserStat.last.min
  end
end