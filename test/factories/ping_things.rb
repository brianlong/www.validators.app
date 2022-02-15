# frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing do
    user
    amount { "" }
    signature { "0d7f418e4d1a3f80dc8a266cd867f766b73d9c80feea36524dfd074068bdef9221e356c192ac6ac71b71404d" }
    response_time { 1 }
    transaction_type { "transfer" }
  end
end
