FactoryBot.define do
  factory :validator_ip do
    version { 1 }
    address { Faker::Internet.ip_v4_address  }
    # address { "MyString" }

    trait :active do 
      is_active { true }
    end
  end
end
