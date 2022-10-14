# frozen_string_literal: true

class LeadersChannel < ApplicationCable::Channel
  def subscribed
    stream_from "leaders_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
