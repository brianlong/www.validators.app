# frozen_string_literal: true

FactoryBot.define do
  factory :gossip_node do
    ip { Faker::Internet.ip_v4_address }
    tpu_port { 8000 }
    gossip_port { 8001 }
    software_version { Faker::App.semantic_version }
    network { "testnet" }
    is_active { true }
  end

  trait :inactive do
    is_active { false }
  end
end
