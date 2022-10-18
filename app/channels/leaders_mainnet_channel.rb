# frozen_string_literal: true

class LeadersMainnetChannel < ApplicationCable::Channel
  def subscribed
    stream_from "leaders_mainnet_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
