# frozen_string_literal: true

require "test_helper"

class PingThingUserStatChannelTest < ActionCable::Channel::TestCase
  setup do
    @text = "sample message"
    @channel = "ping_thing_user_stat_channel"
  end

  test "broadcast to ping_thing_user_stat_channel returns new messages" do
    assert_broadcasts @channel, 0

    ActionCable.server.broadcast @channel, { text: @text }

    assert_broadcasts @channel, 1
    assert_broadcast_on(@channel, text: @text)
  end
end
