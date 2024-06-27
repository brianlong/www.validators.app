# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

NETWORKS.each do |network|
    Blockchain::Transaction.network(network).find_in_batches(batch_size: 1_000_00) do |batch|
        puts "Deleting #{batch.count} transactions for #{network}"
        Blockchain::Transaction.network(network).where("id BETWEEN ? AND ?", batch.first.id, batch.last.id).delete_all
    end

    Blockchain::Block.network(network).find_in_batches(batch_size: 1_000_00) do |batch|
        puts "Deleting #{batch.count} blocks for #{network}"
        Blockchain::Block.network(network).where("id BETWEEN ? AND ?", batch.first.id, batch.last.id).delete_all
    end

    Blockchain::Slot.network(network).find_in_batches(batch_size: 1_000_00) do |batch|
        puts "Deleting #{batch.count} slots for #{network}"
        Blockchain::Slot.network(network).where("id BETWEEN ? AND ?", batch.first.id, batch.last.id).delete_all
    end

    Blockchain::TransactionArchive.network(network).find_in_batches(batch_size: 1_000_00) do |batch|
        puts "Deleting #{batch.count} transaction archives for #{network}"
        Blockchain::TransactionArchive.network(network).where("id BETWEEN ? AND ?", batch.first.id, batch.last.id).delete_all
    end

    Blockchain::BlockArchive.network(network).find_in_batches(batch_size: 1_000_00) do |batch|
        puts "Deleting #{batch.count} block archives for #{network}"
        Blockchain::BlockArchive.network(network).where("id BETWEEN ? AND ?", batch.first.id, batch.last.id).delete_all
    end

    Blockchain::SlotArchive.network(network).find_in_batches(batch_size: 1_000_00) do |batch|
        puts "Deleting #{batch.count} slot archives for #{network}"
        Blockchain::SlotArchive.network(network).where("id BETWEEN ? AND ?", batch.first.id, batch.last.id).delete_all
    end
end