# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

NETWORKS.each do |network|
  current_epoch = EpochWallClock.by_network(network).first&.epoch
  if current_epoch
    epochs_to_get = [current_epoch, current_epoch + 1]

    epochs_to_get.each do |epoch|
      Blockchain::GetLeaderScheduleService.new(network, epoch).call
    end
  end
end
