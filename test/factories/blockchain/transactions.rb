# frozen_string_literal: true

FactoryBot.define do
  factory :mainnet_transaction, class: Blockchain::MainnetTransaction do
    slot_number { "" }
    fee { "" }
    pre_balances { "" }
    post_balances { "" }
    account_key_1 { "MyString" }
    account_key_2 { "MyString" }
    account_key_3 { "MyString" }
    block { create(:mainnet_block) }
  end

  factory :testnet_transaction, class: Blockchain::TestnetTransaction do
    slot_number { "" }
    fee { "" }
    pre_balances { "" }
    post_balances { "" }
    account_key_1 { "MyString" }
    account_key_2 { "MyString" }
    account_key_3 { "MyString" }
    block { create(:testnet_block) }
  end

  factory :pythnet_transaction, class: Blockchain::PythnetTransaction do
    slot_number { "" }
    fee { "" }
    pre_balances { "" }
    post_balances { "" }
    account_key_1 { "MyString" }
    account_key_2 { "MyString" }
    account_key_3 { "MyString" }
    block { create(:pythnet_block) }
  end
end
