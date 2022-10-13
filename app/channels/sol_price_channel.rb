# frozen_string_literal: true

class SolPriceChannel < ApplicationCable::Channel
  def subscribed
    stream_from "sol_price_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
