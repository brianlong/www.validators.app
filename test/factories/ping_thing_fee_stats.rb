FactoryBot.define do
  factory :ping_thing_fee_stat do
    network { "MyString" }
    fee { 1.5 }
    average_time { 1.5 }
    median_time { 1.5 }
    p90_time { 1.5 }
    min_time { 1.5 }
    min_slot_latency { 1.5 }
    median_slot_latency { 1.5 }
    p90_slot_latency { 1.5 }
  end
end
