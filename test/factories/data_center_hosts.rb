# frozen_string_literal: true

FactoryBot.define do
  factory :data_center_host do
    data_center
    host { "ip-192.168.0.0" }
  end
end
