# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

Blockchain::Transaction.find_in_batches(batch_size: 500_000).with_index do |batch, index|
  puts "Transactions: deleted #{index * 500_000}"
  Blockchain::Transaction.where("id < ?", batch.last.id).delete_all
end

Blockchain::Block.find_in_batches(batch_size: 500_000).with_index do |batch, index|
  puts "Blocks: deleted #{index * 500_000}"
  Blockchain::Block.where("id < ?", batch.last.id).delete_all
end

Blockchain::Slot.find_in_batches(batch_size: 500_000).with_index do |batch, index|
  puts "Slots: deleted #{index * 500_000}"
  Blockchain::Slot.where("id < ?", batch.last.id).delete_all
end

Blockchain::TransactionArchive.find_in_batches(batch_size: 500_000).with_index do |batch, index|
  puts "Archived transactions: deleted #{index * 500_000}"
  Blockchain::TransactionArchive.where("id < ?", batch.last.id).delete_all
end

Blockchain::BlockArchive.find_in_batches(batch_size: 500_000).with_index do |batch, index|
  puts "Archived blocks: deleted #{index * 500_000}"
  Blockchain::BlockArchive.where("id < ?", batch.last.id).delete_all
end

Blockchain::SlotArchive.find_in_batches(batch_size: 500_000).with_index do |batch, index|
  puts "Archived slots: deleted #{index * 500_000}"
  Blockchain::SlotArchive.where("id < ?", batch.last.id).delete_all
end