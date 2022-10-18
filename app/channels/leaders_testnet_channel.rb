# frozen_string_literal: true

class LeadersTestnetChannel < ApplicationCable::Channel
  def subscribed
    stream_from "leaders_testnet_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
