# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/fill_skipped_slot_all_average_in_batches.rb

require_relative '../config/environment'
log_path = File.join(Rails.root, 'log', 'fill_skipped_slot_all_average_in_batches.log')
logger = Logger.new(log_path)

Batch.where('skipped_slot_all_average = 0.0 OR skipped_slot_all_average IS NULL')
     .find_each do |batch|

  batch_uuid = batch.uuid
  network = batch.network

  vbh = ValidatorBlockHistory.where(network: network, batch_uuid: batch_uuid)
  vbhq = ValidatorBlockHistoryQuery.new(network, batch_uuid)
  average = vbhq.average_skipped_slot_percent

  next unless average.present?

  if batch.update(skipped_slot_all_average: average)
    puts "Batch with uuid #{batch_uuid} from #{network} updated with average: #{average}.\n"
  end
  
rescue StandardError => e
  logger.error "Batch id: #{batch.id}, message: #{e.message}\n#{e.backtrace}"
  puts 'Error occurred, more info in log/fill_skipped_slot_all_average_in_batches.log'
  sleep(1)
# Go slow since this is just a 1-time backfill
end
