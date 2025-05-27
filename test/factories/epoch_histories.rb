# frozen_string_literal: true

FactoryBot.define do
  factory :epoch_history do
    batch_uuid { "MyString" }
    epoch { 1 }
    current_slot { "" }
    slot_index { 1 }
    slots_in_epoch { 1 }
  end
end
