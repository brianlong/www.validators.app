FactoryBot.define do
  factory :policy do
    pubkey { 'testpubkey123' }
    mint { 'testpubkey123' }
    name { 'Insurance Policy' }
    owner { 'owner1' }
    kind { true }
    strategy { false }
    executable { false }
    url { 'MyString' }
    lamports { '' }
    rent_epoch { '' }
  end
end
