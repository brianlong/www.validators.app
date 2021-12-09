# frozen_string_literal: true

FactoryBot.define do
  factory :validator do
    network { 'testnet' }
    account { SecureRandom.hex }
    name { 'john doe' }
    keybase_id { 'johndoe' }
    security_report_url { 'http://www.example.com' }
    avatar_url { 'http://www.avatar_url.com' }

    trait :with_score do
      after(:create) do |validator|
        create :validator_score_v1, validator: validator
        create :validator_score_v2, validator: validator
      end
    end

    trait :mainnet do
      network { 'mainnet' }
    end
  end
end
