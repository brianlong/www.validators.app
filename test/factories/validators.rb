# frozen_string_literal: true

FactoryBot.define do
  factory :validator do
    network { 'testnet' }
    account { SecureRandom.hex }
    name { 'john doe' }
    keybase_id { 'johndoe' }
    security_report_url { 'http://www.example.com' }
    avatar_url { 'http://www.avatar_url.com' }
    consensus_mods { false }
    is_dz { false }

    trait :with_score do
      after(:create) do |validator|
        create :validator_score_v1, validator: validator, network: validator.network
      end
    end

    trait :mainnet do
      network { 'mainnet' }
    end

    trait :with_validator_ip do
      after(:create) do |validator|
        create :validator_ip, :active, validator: validator
      end
    end

    trait :with_data_center_through_validator_ip do
      after(:create) do |validator|
        create :validator_ip, :active, :with_data_center, validator: validator
      end
    end

    trait :with_consensus_mods_true do
      consensus_mods { true }
    end

    trait :with_admin_warning do
      admin_warning { "test warning" }
    end

    trait :delinquent do
      after(:create) do |validator|
        create :validator_score_v1, validator: validator, network: validator.network, delinquent: true
      end
    end

    trait :private do
      network { "mainnet" }
      after(:create) do |validator|
        create :validator_score_v1, validator: validator, network: validator.network, commission: 100
      end
    end
  end
end
