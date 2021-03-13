FactoryBot.define do
  factory :validator_block_history do
    leader_slots { 1 }
    blocks_produced { 1 }
    skipped_slots { 1 }
    skipped_slot_percent { "9.99" }
  end
end
