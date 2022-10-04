# frozen_string_literal: true

class ActiveStakeChannel < ApplicationCable::Channel
  def subscribed
    stream_from "active_stake_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
