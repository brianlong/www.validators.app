FactoryBot.define do
  factory :blockchain_slot, class: 'Blockchain::Slot' do
    slot_number { "" }
    leader { "MyString" }
    network { "MyString" }
    epoch { 1 }
    has_block { false }
  end
end
