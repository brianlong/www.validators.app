# frozen_string_literal: true

FactoryBot.define do
  factory :stake_account do
    account_balance { 100 }
    activation_epoch { 200 }
    active_stake { 100 }
    credits_observed { 100 }
    deactivating_stake { 100 }
    deactivation_epoch { 200 }
    delegated_stake { 200 }
    delegated_vote_account_address { "delegated_vote_account_address" }
    rent_exempt_reserve { 1 }
    stake_pubkey { "stake_pubkey" }
    stake_type { "stake_type" }
    staker { "staker" }
    withdrawer { "withdrawer" }
    batch_uuid {"123-abc"}
    network { "testnet" }
  end
end
