# frozen_string_literal: true

FactoryBot.define do
  factory :validator_block_history do
    leader_slots { 1 }
    blocks_produced { 1 }
    skipped_slots { 1 }
    skipped_slot_percent { 0.25 }
    network { 'testnet' }
    validator
  end
end
