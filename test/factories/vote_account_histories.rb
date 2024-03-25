# frozen_string_literal: true

FactoryBot.define do
  factory :vote_account_history do
    vote_account_id { 1 }
    network { 'testnet' }
    batch_uuid { '1-2-3' }
    software_version { 'version one' }
    last_vote { 1 }
    activated_stake { 1000000000 }
    credits { 1 }
    credits_current { 193916 }
    slot_index_current { 299198 }
    skipped_vote_percent_moving_average { 0.1 }
    root_slot { 2 }
  end
end
