# frozen_string_literal: true

FactoryBot.define do
  factory :mainnet_slot, class: Blockchain::MainnetSlot do
    slot_number { 123 }
    leader { "account_1" }
    epoch { 586 }
    status { "initialized" }
  end

  factory :testnet_slot, class: Blockchain::TestnetSlot do
    slot_number { 123 }
    leader { "account_1" }
    epoch { 586 }
    status { "initialized" }
  end

  factory :pythnet_slot, class: Blockchain::PythnetSlot do
    slot_number { 123 }
    leader { "account_1" }
    epoch { 586 }
    status { "initialized" }
  end
end
