# frozen_string_literal: true

class PingThingUserStatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ping_thing_user_stat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
