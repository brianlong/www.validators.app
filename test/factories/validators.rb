# frozen_string_literal: true

FactoryBot.define do
  factory :validator do
    network { 'testnet' }
    account { '12345678' }
  end

  # trait :with_validator_score_v1 do
  #   validator_score_v1
  # end
end
