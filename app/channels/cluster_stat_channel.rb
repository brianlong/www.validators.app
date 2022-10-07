# frozen_string_literal: true

class ClusterStatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "cluster_stat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def current_total_active_stake
    ActionCable.server.broadcast("cluster_stat_channel", ClusterStat.last.total_active_stake)
  end
end
