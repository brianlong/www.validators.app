# frozen_string_literal: true

class PingThingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "ping_thing_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
