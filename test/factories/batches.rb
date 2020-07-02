# frozen_string_literal: true

FactoryBot.define do
  factory :batch do
    uuid { SecureRandom.uuid }
  end
end
