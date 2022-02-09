#frozen_string_literal: true

FactoryBot.define do
  factory :ping_thing do
    user { nil }
    amount { "" }
    signature { "MyString" }
    response_time { 1 }
    transaction_type { "MyString" }
  end
end
