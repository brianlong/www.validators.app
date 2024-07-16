#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 2
EPOCHS_BACK = 10
SLEEP_TIME = 60 * 10
ARCHIVE = false

network = ARGV[0]

raise "Network is required and should be one of: #{NETWORKS.join(', ')}" unless NETWORKS.include?(network)

loop do
  current_epoch = EpochWallClock.where(network: network).order(epoch: :desc).first
  unless current_epoch
    sleep SLEEP_TIME
    next
  end

  target_epoch = current_epoch&.epoch - EPOCHS_KEPT

  ((target_epoch - EPOCHS_BACK)...target_epoch).each do |epoch_to_clear|
    Blockchain::ArchiveBlockchainService.new(archive: ARCHIVE, network: network, epoch: epoch_to_clear).call
  end
  sleep SLEEP_TIME
end
