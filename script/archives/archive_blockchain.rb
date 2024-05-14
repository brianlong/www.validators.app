#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 6

NETWORKS.each do |network|
  current_epoch = EpochWallClock.where(network: network).order(epoch: :desc).first
  next unless current_epoch
  Blockchain::Slot.where(network: network)
                  .where("epoch < ?", current_epoch.epoch - EPOCHS_KEPT)
                  .find_each do |slot|

    Blockchain::Transaction.where(slot_number: slot.slot_number).find_each do |transaction|
      Blockchain::Transaction.archive(transaction, destroy_after_archive: true)
    end
    Blockchain::Block.where(slot_number: slot.slot_number).find_each do |block|
      Blockchain::Block.archive(block, destroy_after_archive: true)
    end
    Blockchain::Slot.archive(slot, destroy_after_archive: true)
  end
end
