# frozen_string_literal: true

FactoryBot.define do
  factory :validator_history do
    network { "testnet" }
    batch_uuid { "MyString" }
    account { SecureRandom.hex }
    vote_account { "MyString" }
    commission { "9.99" }
    last_vote { 5 }
    credits { 1 }
    active_stake { 100000 }
    delinquent { false }
    root_distance { 5 }
    root_block { 5 }
    vote_distance { 5 }
    slot_skip_rate { 1.5 }
    software_version { '1.1.1' }
    software_client { 'Agave' }
    software_client_id { 3 }
    validator
  end
end
