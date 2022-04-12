# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing_stat do
    interval { 1 }
    min { 50 }
    max { 120 }
    median { 82 }
    num_of_records { "" }
    network { "testnet" }
    time_from { DateTime.now }
  end
end
