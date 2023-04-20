# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

LAST_EPOCH_SIZE = 5

NETWORKS.each do |network|
  stats = ClusterStat.by_network(network).last
  epochs = EpochWallClock.where(network: network).last(LAST_EPOCH_SIZE)
  epoch_duration = (epochs.last.created_at - epochs.first.created_at) / LAST_EPOCH_SIZE

  unless stats.update(epoch_duration: epoch_duration)
    Appsignal.send_error(stats.errors.full_messages)
  end
end
