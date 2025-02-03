# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing do
    amount { "" }
    application { "Mango" }
    network { "mainnet" }
    response_time { 1 }
    signature { "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s" }
    success { true }
    transaction_type { "transfer" }
    reported_at { Time.now }
    user { create(:user, :ping_thing_user, :confirmed) }
    slot_sent { 123 }
    slot_landed { 125 }
    priority_fee_micro_lamports { 1234 }
    priority_fee_percentile { 50 }
    pinger_region { "lon" }

    trait :processed do
      commitment_level { 0 }
    end

    trait :confirmed do
      commitment_level { 1 }
    end

    trait :finalized do
      commitment_level { 2 }
    end

    trait :mainnet do
      network { "mainnet" }
    end

    trait :testnet do
      network { "testnet" }
    end
  end
end
