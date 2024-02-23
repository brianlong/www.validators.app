#frozen_string_literal: true

FactoryBot.define do
  factory :vote_account_stake_history do
    account_balance { 1234 }
    activation_epoch { 121 }
    active_stake { 567 }
    credits_observed { 8910 }
    deactivating_stake { 1112 }
    deactivation_epoch { 1314 }
    delegated_stake { 1516 }
    rent_exempt_reserve { 1718 }
    stake_type { "stake_type" }
    network { "testnet" }
    epoch { 123 }
    vote_account { create(:vote_account) }
  end
end
