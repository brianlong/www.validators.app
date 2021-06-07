# frozen_string_literal: true

FactoryBot.define do
  factory :validator_score_v1 do
    validator
    total_score { 5 }
    root_distance_history { [149] }
    root_distance_score { 1 }
    vote_distance_history { [1] }
    vote_distance_score { 2 }
    skipped_slot_history { [0.2059] }
    skipped_slot_score { 0 }
    skipped_after_history { nil }
    skipped_after_score { nil }
    software_version { '1.6.7' }
    software_version_score { 2 }
    stake_concentration { 0.1e-2 }
    stake_concentration_score { 0 }
    data_center_concentration { nil }
    data_center_concentration_score { nil }
    active_stake { 206_356_743_328_737 }
    commission { 10 }
    ping_time_avg { nil }
    delinquent { false }
    created_at { '2021-05-31 09:36:22.431402000 +0000' }
    updated_at { '2021-05-31 09:44:56.249538000 +0000' }
    published_information_score { 0 }
    security_report_score { 0 }
    ip_address { '172.96.172.252' }
    network { 'mainnet' }
    data_center_key { '23470-US-America/Chicago' }
    data_center_host { nil }
    skipped_slot_moving_average_history { [0.2051] }
    skipped_vote_history { nil }
    skipped_vote_percent_moving_average_history { nil }
  end
end
