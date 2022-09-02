FactoryBot.define do
  factory :data_center_stat do
    gossip_nodes_count { 1 }
    validators_count { 1 }
    data_ceters { nil }
  end
end
