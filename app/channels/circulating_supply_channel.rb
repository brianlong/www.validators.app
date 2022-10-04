# frozen_string_literal: true

class CirculatingSupplyChannel < ApplicationCable::Channel
  def subscribed
    stream_from "circulating_supply_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
