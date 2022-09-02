FactoryBot.define do
  factory :data_center_stat do
    gossip_nodes_count { 1 }
    validators_count { 1 }
    data_center_id { create(:data_center).id }
    network { "testnet" }
  end
end
