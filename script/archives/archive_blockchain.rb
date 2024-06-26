#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 2
EPOCHS_BACK = 10

NETWORKS.each do |network|
  current_epoch = EpochWallClock.where(network: network).order(epoch: :desc).first
  next unless current_epoch
  target_epoch = current_epoch&.epoch - EPOCHS_KEPT

  ((target_epoch - EPOCHS_BACK)...target_epoch).each do |epoch_to_clear|
    if Blockchain::Slot.where(network: network, epoch: epoch_to_clear).exists?
      Parallel.each(Blockchain::Slot.where(network: network, epoch: epoch_to_clear).find_in_batches(batch_size: 50), in_threads: 3) do |batch|
        start_time = Time.now
        slot_numbers = batch.map(&:slot_number)

        block_batch = Blockchain::Block.where(network: network, slot_number: slot_numbers).to_a
        transaction_batch = Blockchain::Transaction.where(block_id: block_batch.map(&:id)).to_a

        puts "Archiving #{transaction_batch.count} transactions, #{block_batch.count} blocks, and #{batch.count} slots for epoch #{epoch_to_clear} (#{network}) in thread #{Parallel.worker_number}"
        
        Blockchain::Transaction.archive_batch(transaction_batch, destroy_after_archive: true) unless transaction_batch.empty?
        Blockchain::Block.archive_batch(block_batch, destroy_after_archive: true) unless block_batch.empty?
        Blockchain::Slot.archive_batch(batch, destroy_after_archive: true) unless batch.empty?
        puts "Archived thread #{Parallel.worker_number} in #{Time.now - start_time} seconds"
      end
    end
  end
end
