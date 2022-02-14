# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing_raw do
    api_token { "api_token" }
    network { "mainnet" }
    raw_data { 
      {
        amount: rand(1..100),
        application: 'Mango',
        commitment_level: 'finalized',
        signature: SecureRandom.hex(46),
        success: true,
        time: rand(1..1000),
        transaction_type: "transfer"
      }.to_json
    }
  end
end
