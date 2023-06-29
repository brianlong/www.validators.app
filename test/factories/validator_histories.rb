FactoryBot.define do
  factory :validator_history do
    network { "testnet" }
    batch_uuid { "MyString" }
    account { SecureRandom.hex }
    vote_account { "MyString" }
    commission { "9.99" }
    last_vote { "" }
    root_block { "" }
    credits { 1 }
    active_stake { 100 }
    delinquent { false }
    validator
  end
end
