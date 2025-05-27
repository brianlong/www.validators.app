# frozen_string_literal: true

FactoryBot.define do
  factory :vote_account do
    # references { "" }
    validator
    account { 'Test Account' }
    network { 'testnet' }
  end
end
