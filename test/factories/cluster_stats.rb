# frozen_string_literal: true

FactoryBot.define do
  factory :cluster_stat do
    network { "testnet" }
    total_active_stake { rand(10..1000) }
  end
end
