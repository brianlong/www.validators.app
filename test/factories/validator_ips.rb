# frozen_string_literal: true

FactoryBot.define do
  factory :validator_ip do
    version { 1 }
    address { Faker::Internet.ip_v4_address  }
    # address { "MyString" }

    trait :active do
      is_active { true }
    end

    trait :muted do
      is_muted { true }
    end

    trait :with_data_center do
      data_center_host
    end
  end
end
