# frozen_string_literal: true

FactoryBot.define do
  factory :contact_request do
    name { Faker::Name.name[0..15] }
    email_address { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    comments { Faker::Lorem.sentence }
  end
end
