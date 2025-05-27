# frozen_string_literal: true

FactoryBot.define do
  factory :stake_account_history do
    account_balance { 1 }
    activation_epoch { 1 }
    active_stake { 1 }
    credits_observed { 1 }
    deactivating_stake { 1 }
    deactivation_epoch { 1 }
    delegated_stake { 1 }
    delegated_vote_account_address { "MyString" }
    rent_exempt_reserve { 1 }
    stake_pubkey { "MyString" }
    stake_type { "MyString" }
    staker { "MyString" }
    withdrawer { "MyString" }
    stake_pool_id { 1 }
  end
end
