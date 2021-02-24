FactoryBot.define do
  factory :block_commitment do
    network { "MyString" }
    # epoch { "" }
    slot { "" }
    commitment { "MyText" }
    total_stake { "" }
  end
end
