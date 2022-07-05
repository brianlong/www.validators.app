# frozen_string_literal: true

require "test_helper"

class PingThingStatTest < ActiveSupport::TestCase
  include ActionCable::TestHelper

  setup do
    @network = "testnet"
    @usr = create(:user)

    4.times do |n|
      create(
        :ping_thing,
        network: @network,
        user: @usr,
        response_time: n,
        reported_at: DateTime.now - (n.minutes + 5.seconds)
      )
    end
  end

  test "recalculate updates stats correctly" do
    stat = create(:ping_thing_stat, network: @network, interval: 3, time_from: 4.minutes.ago)

    stat.recalculate
    stat.reload

    assert_equal 3, stat.max
    assert_equal 1, stat.min
    assert_equal 2, stat.median
    assert_equal 3, stat.num_of_records
  end

  test "self.between_time_range returns correct ping thing stats" do
    stat = create(:ping_thing_stat, network: @network, interval: 3, time_from: 4.minutes.ago)

    assert_equal stat.id, PingThingStat.between_time_range(3.minutes.ago).pluck(:id).first
    refute PingThingStat.between_time_range(5.minutes.ago).exists?
    refute PingThingStat.between_time_range(DateTime.now).exists?
  end

  test "#to_builder returns required attributtes" do
    ping_thing_stat = create(:ping_thing_stat)
    required_keys = PingThingStat::FIELDS_FOR_API.map(&:to_s)

    assert_equal required_keys, ping_thing_stat.to_builder.attributes!.keys
  end

  test "creating new record brodcasts message" do
    channel = "ping_thing_stat_channel"

    assert_broadcasts channel, 0

    ping_thing_stat = create(:ping_thing_stat)

    assert_broadcasts channel, 1
    assert_broadcast_on(channel, ping_thing_stat.to_json)
  end
end
