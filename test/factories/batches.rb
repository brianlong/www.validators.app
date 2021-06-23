# frozen_string_literal: true

FactoryBot.define do
  factory :batch do
    uuid { SecureRandom.uuid }
    scored_at { Time.now }
    network { 'testnet' }
  end
end
