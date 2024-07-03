#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 1
EPOCHS_BACK = 10
NETWORK = "pythnet"
SLEEP_TIME = 60 * 10

ARCHIVE = Rails.env.production?



loop do
  current_epoch = EpochWallClock.where(network: NETWORK).order(epoch: :desc).first
  unless current_epoch
    sleep SLEEP_TIME
    next
  end

  target_epoch = current_epoch&.epoch - EPOCHS_KEPT

  ((target_epoch - EPOCHS_BACK)...target_epoch).each do |epoch_to_clear|
    Blockchain::ArchiveBlockchainService.new(archive: ARCHIVE, network: NETWORK, epoch: epoch_to_clear).call
  end
  sleep SLEEP_TIME
end