# frozen_string_literal: true

FactoryBot.define do
  factory :validator_score_v1 do
  end

  trait :with_validator do
    validator
  end
end
