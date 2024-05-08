#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 6
EPOCHS_BACK = 10

NETWORKS.each do |network|
  current_epoch = EpochWallClock.where(network: network).order(epoch: :desc)&.first
  next unless current_epoch
  target_epoch = current_epoch&.epoch - EPOCHS_KEPT

  ((target_epoch - EPOCHS_BACK)...target_epoch).each do |epoch_to_clear|
    if Blockchain::Slot.where(network: network, epoch: epoch_to_clear).exists?
      Blockchain::Transaction.where(network: network, epoch: epoch_to_clear).find_in_batches(batch_size: 100) do |batch|
        Blockchain::Transaction.archive_batch(batch, destroy_after_archive: true)
      end

      Blockchain::Block.where(network: network, epoch: epoch_to_clear).find_in_batches(batch_size: 100) do |batch|
        Blockchain::Block.archive_batch(batch, destroy_after_archive: true)
      end

      Blockchain::Slot.where(network: network, epoch: epoch_to_clear).find_in_batches(batch_size: 100) do |batch|
        Blockchain::Slot.archive_batch(batch, destroy_after_archive: true)
      end
    end
  end
end
