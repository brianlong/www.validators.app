# frozen_string_literal: true

FactoryBot.define do
  factory :collector do
    payload_type { '' }
    payload_version { 1 }
    payload { 'MyText' }
    ip_address { 'MyString' }
  end
end
