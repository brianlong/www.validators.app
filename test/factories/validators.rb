# frozen_string_literal: true

FactoryBot.define do
  factory :validator do
    network { 'testnet' }
    account { '12345678' }
    name { 'john doe' }
    keybase_id { 'johndoe' }
    security_report_url { 'http://www.example.com' }
  end
end
