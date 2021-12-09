# frozen_string_literal: true

FactoryBot.define do
  factory :batch do
    uuid { SecureRandom.uuid }
    scored_at { Time.now }
    scored_at_v2 { Time.now }
    network { 'testnet' }
  end
end
