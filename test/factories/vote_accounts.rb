FactoryBot.define do
  factory :vote_account do
    # references { "" }
    validator
    account { 'Test Account' }
    network { 'testnet' }

    trait :active do
      is_active { true }
    end
  end
end
