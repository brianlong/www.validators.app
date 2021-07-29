# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/back_fill_validator_histories.rb

require_relative '../config/environment'
log_path = File.join(Rails.root, 'log', 'fill_average_skipped_slot_percent_in_batches.txt')
logger = Logger.new(log_path)

Batch.find_each do |batch|
  batch_uuid = batch.uuid
  network = batch.network

  vbh = ValidatorBlockHistory.where(network: network, batch_uuid: batch_uuid)
  vbhq = ValidatorBlockHistoryQuery.new(network, batch_uuid)
  average = vbhq.average_skipped_slot_percent

  if batch.update(average_skipped_slot_percent: average)
    puts "Batch with uuid #{batch_uuid} from #{network} updated with average: #{average}.\n"
  end
  
  rescue StandardError => e
    logger.error "Batch id: #{batch.id}, message: #{e.message}\n#{e.backtrace}"
    sleep(1)
  # Go slow since this is just a 1-time backfill
end
