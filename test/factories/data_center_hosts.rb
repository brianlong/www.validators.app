# frozen_string_literal: true

FactoryBot.define do
  factory :data_center_host do
    data_center
    host { Faker::Internet.ip_v4_address }
  end
end
