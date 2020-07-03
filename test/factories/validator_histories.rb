FactoryBot.define do
  factory :validator_history do
    batch_uuid { "MyString" }
    account { "MyString" }
    vote_account { "MyString" }
    commission { "9.99" }
    last_vote { "" }
    root_block { "" }
    credits { 1 }
    active_Stake { "9.99" }
    delinquent { false }
  end
end
