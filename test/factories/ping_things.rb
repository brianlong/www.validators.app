# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing do
    user { nil }
    amount { "" }
    signature { "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s" }
    response_time { 1 }
    transaction_type { "MyString" }
    network { "mainnet" }
    success { true }
    application { "Mango" }

    trait :processed do
      commitment_level { 0 }
    end

    trait :confirmed do
      commitment_level { 1 }
    end

    trait :finalized do
      commitment_level { 2 }
    end
  end
end
