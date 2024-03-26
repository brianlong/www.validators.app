# frozen_string_literal: true

FactoryBot.define do
  factory :asn_stat do
    average_score { 1.5 }
    traits_autonomous_system_number { 1 }
    calculated_at { "2021-08-19 10:54:57" }
    population { 1 }
    active_stake { 1.5 }
    data_centers { "" }
  end
end
