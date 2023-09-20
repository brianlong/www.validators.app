FactoryBot.define do
  factory :explorer_stake_account do
    account_balance { 1234 }
    activation_epoch { 121 }
    active_stake { 567 }
    credits_observed { 8910 }
    deactivating_stake { 1112 }
    deactivation_epoch { 1314 }
    delegated_stake { 1516 }
    delegated_vote_account_address { "vote_account_address" }
    rent_exempt_reserve { 1718 }
    stake_pubkey { "stake_pubkey" }
    stake_type { "stake_type" }
    staker { "staker" }
    withdrawer { "withdrawer" }
    network { "testnet" }
    epoch { 123 }
  end
end
