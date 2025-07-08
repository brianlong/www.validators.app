FactoryBot.define do
  factory :policy do
    pubkey { Faker::Lorem.characters(number: 44) }
    mint { Faker::Lorem.characters(number: 44) }
    name { 'Insurance Policy' }
    owner { 'owner1' }
    kind { 1 }
    strategy { false }
    executable { false }
    url { 'MyString' }
    lamports { '' }
    rent_epoch { '' }
    additional_metadata { [] }
    description { 'Policy Description' }
    image { '' }
    network { "mainnet" }
    symbol { 'ABC' }
  end
end
