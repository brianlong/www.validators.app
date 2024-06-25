# frozen_string_literal: true

FactoryBot.define do
  factory :blockchain_slot, class: Blockchain::Slot do
    slot_number { 123 }
    leader { "account_1" }
    network { "mainnet" }
    epoch { 586 }
    status { "initialized" }
  end
end
