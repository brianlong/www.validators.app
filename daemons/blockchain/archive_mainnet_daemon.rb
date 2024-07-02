#frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)

EPOCHS_KEPT = 2
EPOCHS_BACK = 10
NETWORK = "mainnet"

ARCHIVE = true

def group_ids ids
  arrays = []
  ids.each do |id|
    if arrays.empty?
      arrays << [id]
    else
      if id == arrays.last.last + 1
        arrays.last << id
      else
        arrays << [id]
      end
    end
  end
  arrays
end

loop do
  current_epoch = EpochWallClock.where(network: NETWORK).order(epoch: :desc).first
  next unless current_epoch
  target_epoch = current_epoch&.epoch - EPOCHS_KEPT

  ((target_epoch - EPOCHS_BACK)...target_epoch).each do |epoch_to_clear|
    if Blockchain::Slot.network(NETWORK).where(epoch: epoch_to_clear).exists?
      begin
        Parallel.each(Blockchain::Slot.network(NETWORK).where(epoch: epoch_to_clear).find_in_batches(batch_size: 100), in_processess: 3) do |batch|
          start_time = Time.now

          slot_numbers = batch.map(&:slot_number)
          block_batch = Blockchain::Block.network(NETWORK).where(slot_number: slot_numbers).to_a
          transaction_batch = Blockchain::Transaction.network(NETWORK).where(block_id: block_batch.map(&:id)).to_a

          if transaction_batch.any?
            Blockchain::Transaction.network(NETWORK).archive_batch(transaction_batch, archive: ARCHIVE, destroy_after_archive: false)
            group_ids(transaction_batch.map(&:id)).each do |ids|
              Blockchain::Transaction.network(NETWORK).where("id BETWEEN ? AND ?", ids.first, ids.last).delete_all
            end
          end
          
          Blockchain::Block.network(NETWORK).archive_batch(block_batch, archive: ARCHIVE, destroy_after_archive: true) unless block_batch.empty?
          Blockchain::Slot.network(NETWORK).archive_batch(batch, archive: ARCHIVE, destroy_after_archive: true) unless batch.empty?
          puts "Archived #{block_batch.count} blocks, and #{batch.count} slots for epoch #{epoch_to_clear} (#{NETWORK}) \
                in thread #{Parallel.worker_number} in #{Time.now - start_time} seconds"
        end
      rescue Parallel::DeadWorker
        puts "DeadWorker error, retrying in 5 seconds"
        sleep 5
        retry
      end
    end
  end
  puts "Sleeping for 60 seconds"
  sleep 60
end