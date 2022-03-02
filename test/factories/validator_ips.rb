FactoryBot.define do
  factory :validator_ip do
    version { 4 }
    address { Faker::Internet.ip_v4_address }
  end
end
