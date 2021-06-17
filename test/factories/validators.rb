# frozen_string_literal: true

FactoryBot.define do
  factory :validator do
    network { 'testnet' }
    account { SecureRandom.hex }
    name { 'john doe' }
    keybase_id { 'johndoe' }
    security_report_url { 'http://www.example.com' }

    trait :with_score do
      validator_score_v1
    end

    trait :mainnet do
      network { 'mainnet' }
    end
  end
end
