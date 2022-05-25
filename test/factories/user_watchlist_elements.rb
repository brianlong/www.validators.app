FactoryBot.define do
  factory :user_watchlist_element do
    user { nil }
    validator { nil }
    network { "testnet" }
  end
end
