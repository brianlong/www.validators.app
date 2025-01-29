# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing_raw do
    api_token { "api_token" }
    network { "mainnet" }
    raw_data { 
      {
        amount: rand(1..100),
        application: "Mango",
        commitment_level: "finalized",
        signature: SecureRandom.hex(46),
        success: true,
        time: rand(1..1000),
        transaction_type: "transfer",
        reported_at: Time.now,
        priority_fee_micro_lamports: 5000,
        priority_fee_percentile: 50,
        pinger_region: "us-west",
        slot_sent: 100,
        slot_landed: 200
      }.to_json
    }

    trait :invalid_commitment_level do
      raw_data {
        {
          amount: rand(1..100),
          application: "Mango",
          commitment_level: "finished",
          signature: SecureRandom.hex(46),
          success: true,
          time: rand(1..1000),
          transaction_type: "transfer",
          priority_fee_micro_lamports: 5000,
          priority_fee_percentile: 50,
          pinger_region: "us-west"
        }.to_json
      }
    end

    trait :success_empty do
      raw_data {
        {
          signature: "0d7f418e4d1a3f80dc8a266cd867f766b73d9c80feea36524dfd074068bdef9221e356c192ac6ac71b71404d",
          time: 2,
          transaction_type: "transfer"
        }.to_json
      }
    end

    trait :success_false do
      raw_data {
        {
          success: false,
          signature: "0d7f418e4d1a3f80dc8a266cd867f766b73d9c80feea36524dfd074068bdef9221e356c192ac6ac71b71404d",
          time: 2,
          transaction_type: "transfer"
        }.to_json
      }
    end
  end
end
