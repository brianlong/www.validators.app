#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 0
EPOCHS_BACK = 10

NETWORKS.each do |network|
  current_epoch = EpochWallClock.where(network: network).order(epoch: :desc).first
  next unless current_epoch
  target_epoch = current_epoch&.epoch - EPOCHS_KEPT

  ((target_epoch - EPOCHS_BACK)..target_epoch).each do |epoch_to_clear|
    if Blockchain::Slot.network(network).where(epoch: epoch_to_clear).exists?
      Blockchain::Slot.network(network).where(epoch: epoch_to_clear).find_in_batches(batch_size: 100) do |batch|
        start_time = Time.now
        slot_numbers = batch.map(&:slot_number)

        block_batch = Blockchain::Block.network(network).where(slot_number: slot_numbers).to_a
        transaction_batch = Blockchain::Transaction.network(network).where(block_id: block_batch.map(&:id)).to_a

        if transaction_batch.any?
          puts "Archiving #{transaction_batch.count} transactions for epoch #{epoch_to_clear} (#{network})"
          Blockchain::Transaction.network(network).archive_batch(transaction_batch, destroy_after_archive: false)
          puts "saved in #{Time.now - start_time} seconds"
          start_time = Time.now
          puts "deleting #{transaction_batch.count} transactions for epoch #{epoch_to_clear} (#{network})"
          Blockchain::Transaction.network(network).where("id <= ?", transaction_batch.last.id).delete_all
          puts "deleted in #{Time.now - start_time} seconds"
        end
      end

      Parallel.each(Blockchain::Slot.network(network).where(epoch: epoch_to_clear).find_in_batches(batch_size: 50), in_threads: 3) do |batch|
        slot_numbers = batch.map(&:slot_number)
        block_batch = Blockchain::Block.network(network).where(slot_number: slot_numbers).to_a
        puts "Archiving #{block_batch.count} blocks, and #{batch.count} slots for epoch #{epoch_to_clear} (#{network}) in thread #{Parallel.worker_number}"

        Blockchain::Block.network(network).archive_batch(block_batch, destroy_after_archive: true) unless block_batch.empty?
        Blockchain::Slot.network(network).archive_batch(batch, destroy_after_archive: true) unless batch.empty?
      end
    end
  end
end
