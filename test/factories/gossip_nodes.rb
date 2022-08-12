FactoryBot.define do
  factory :gossip_node do
    ip { "MyString" }
    tpu_port { 1 }
    gossip_port { 1 }
    version { "MyString" }
  end
end
