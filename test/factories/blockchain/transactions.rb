# frozen_string_literal: true

FactoryBot.define do
  factory :blockchain_transaction, class: 'Blockchain::Transaction' do
    slot_number { "" }
    fee { "" }
    pre_balances { "" }
    post_balances { "" }
    account_key_1 { "MyString" }
    account_key_2 { "MyString" }
    account_key_3 { "MyString" }
  end
end
