FactoryBot.define do
  factory :validator_ip do
    references { "" }
    version { 1 }
    address { "MyString" }
  end
end
