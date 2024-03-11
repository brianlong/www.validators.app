FactoryBot.define do
  factory :blockchain_slot, class: 'Blockchain::Slot' do
    slot_number { 123 }
    leader { "account_1" }
    network { "mainnet" }
    epoch { 586 }
    has_block { false }
  end
end
