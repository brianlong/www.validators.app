# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/write_validator_histories.rb

require File.expand_path('../config/environment', __dir__)
require 'csv'


CSV.open('/tmp/validator_block_history_stats.csv', 'w') do |csv|
  csv << %w[id network epoch start_slot end_slot total_slots total_blocks_produced total_slots_skipped total_skip_percent created_at]
  ValidatorBlockHistoryStat.where(
    "network = 'mainnet'"
  ).find_each do |vh|
    total_skip_percent = vh.total_slots_skipped.to_i / vh.total_slots.to_f
    csv << [
      vh.id,
      vh.network,
      vh.epoch,
      vh.start_slot,
      vh.end_slot,
      vh.total_slots,
      vh.total_blocks_produced,
      vh.total_slots_skipped,
      total_skip_percent,
      vh.created_at
    ]
  end
end
