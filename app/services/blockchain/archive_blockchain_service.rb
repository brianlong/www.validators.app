# frozen_string_literal: true

module Blockchain
  class ArchiveBlockchainService
    def initialize(archive: true, network: "mainnet", epoch: nil, processes: 3)
      @archive = archive
      @network = network
      @processes = processes
      @epoch_to_clear = epoch
      @current_epoch = EpochWallClock.where(network: @network).order(epoch: :desc).first
      @logger = Logger.new("log/archive_blockchain_#{@network}.log")
    end

    def call
      if Blockchain::Slot.network(@network).where(epoch: @epoch_to_clear).exists?
        begin
          Parallel.each(
            Blockchain::Slot.network(@network).where(epoch: @epoch_to_clear).find_in_batches(batch_size: 100),
            in_processes: @processes
          ) do |batch|

            start_time = Time.now
  
            slot_numbers = batch.map(&:slot_number)
            block_batch = Blockchain::Block.network(@network).where(slot_number: slot_numbers).to_a
            transaction_batch = Blockchain::Transaction.network(@network).where(block_id: block_batch.map(&:id)).to_a
  
            if transaction_batch.any?
              Blockchain::Transaction.network(@network).archive_batch(transaction_batch, archive: true, destroy_after_archive: false)
              group_ids(transaction_batch.map(&:id)).each do |ids|
                Blockchain::Transaction.network(@network).where("id BETWEEN ? AND ?", ids.first, ids.last).delete_all
              end
            end
            
            Blockchain::Block.network(@network).archive_batch(block_batch, archive: @archive, destroy_after_archive: true) unless block_batch.empty?
            Blockchain::Slot.network(@network).archive_batch(batch, archive: @archive, destroy_after_archive: true) unless batch.empty?

            @logger.info <<-STRING.squish
              Archived #{block_batch.count} blocks,
              #{batch.count} slots,
              #{transaction_batch.count} transactions 
              for epoch #{@epoch_to_clear} (#{@network}) \
              in thread #{Parallel.worker_number} in #{Time.now - start_time} seconds"
            STRING
          end
        rescue Parallel::DeadWorker
          @logger.error "DeadWorker error, retrying in 5 seconds"
          sleep 5
          retry
        end
      end
    end

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

  end
end