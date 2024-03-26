# frozen_string_literal: true

FactoryBot.define do
  factory :opt_out_request do
    name { Faker::Name.name[0..15] }
    request_type { 'opt_out' }
    street_address { Faker::Address.street_address }
    city { Faker::Address.city }
    postal_code { Faker::Address.postcode }
    state { Faker::Address.state_abbr }
    meta_data { { ip: '127.0.0.1' } }
  end
end
