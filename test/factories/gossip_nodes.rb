FactoryBot.define do
  factory :gossip_node do
    ip { "0.0.1.1" }
    tpu_port { 8000 }
    gossip_port { 8001 }
    version { "1.2.3" }
  end
end
