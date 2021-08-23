class WallChannel < ApplicationCable::Channel
  def subscribed
    stream_from "wall_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
