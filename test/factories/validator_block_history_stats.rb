# frozen_string_literal: true

FactoryBot.define do
  factory :validator_block_history_stat do
    batch_uuid { "123" }
    epoch { 1 }
    start_slot { 1 }
    end_slot { 10 }
    total_slots { 10 }
    total_blocks_produced { 10 }
    total_slots_skipped { 0 }
    network { "testnet" }
    skipped_slot_percent_moving_average { 0.0 }
  end
end
