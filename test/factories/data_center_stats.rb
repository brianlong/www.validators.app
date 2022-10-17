# frozen_string_literal: true

FactoryBot.define do
  factory :data_center_stat do
    gossip_nodes_count { 1 }
    active_gossip_nodes_count { 1 }
    validators_count { 1 }
    active_validators_count { 1 }
    network { "testnet" }
    data_center
  end
end
