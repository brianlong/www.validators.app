# frozen_string_literal: true

FactoryBot.define do
  factory :user_watchlist_element do
    user
    validator
  end
end
