# frozen_string_literal: true

# We use factory for users due to error in loading fixtures
# because we do not have email field in database.
# Instead we use virtual email attribute, check the model.
FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 8, separators: ["."]) }
    email { "user@fmatemplate.com" }
    password { "Password123" }
    api_token { SecureRandom.uuid }
    is_admin { false }
    

    trait :admin do
      email { "adminone@fmatemplate.com" }
      is_admin { true }
    end

    trait :ping_thing_user do
      email { Faker::Internet.email }
    end

    trait :confirmed do
      confirmed_at { Time.now }
    end
  end
end
