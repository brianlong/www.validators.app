# frozen_string_literal: true

class PingThingRecentStatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ping_thing_recent_stat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
