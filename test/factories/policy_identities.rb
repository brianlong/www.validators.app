# frozen_string_literal: true

FactoryBot.define do
  factory :policy_identity do
    validator
    policy
  end
end
