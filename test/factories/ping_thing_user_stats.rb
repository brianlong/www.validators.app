# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing_user_stat do
    interval { 5 }
    min { 550 }
    max { 7000 }
    median { 5000 }
    p90 { 600 }
    num_of_records { 10 }
    network { "testnet" }

    trait :mainnet do
      network { "mainnet" }
    end

    trait :interval_60 do
      interval { 60 }
      min { 500 }
      max { 15000 }
      median { 5000 }
      p90 { 14000 }
      num_of_records { 100 }
    end
  end
end
