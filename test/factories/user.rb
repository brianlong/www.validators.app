# We use factory for users due to error in loading fixtures
# because we do not have email field in database.
# Instead we use virtual email attribute, check the model.
FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 8) }
    email { 'adminone@fmatemplate.com' }
    password { 'Password123' }
    is_admin { false }
    confirmed_at { Time.now }

    trait :admin do
      username { Faker::Internet.username(specifier: 8) }
      email { 'adminone@fmatemplate.com' }
      is_admin { true }
    end
  end
end
