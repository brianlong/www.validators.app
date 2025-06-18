# frozen_string_literal: true

FactoryBot.define do
  factory :validator_score_v1 do
    validator
    active_stake { 206356743328737 - rand(10_000) }
    root_distance_history { [1, 2, 3, 4, 5] }
    vote_distance_history { [5, 4, 3, 2, 1] }
    skipped_vote_history { [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9] }
    skipped_slot_history { [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1] }
    total_score { 5 }
    root_distance_score { 1 }
    vote_distance_score { 2 }
    skipped_slot_score { 0 }
    skipped_after_history { [0.1230] }
    skipped_after_score { 0 }
    software_version { '1.6.7' }
    software_version_score { 2 }
    stake_concentration { 0.1e-2 }
    stake_concentration_score { 0 }
    data_center_concentration { nil }
    data_center_concentration_score { nil }
    commission { 10 }
    ping_time_avg { nil }
    delinquent { false }
    published_information_score { 0 }
    security_report_score { 0 }
    consensus_mods_score { 0 }
    ip_address { '172.96.172.252' }
    network { 'mainnet' }
    skipped_slot_moving_average_history { [0.2051] }
    skipped_vote_percent_moving_average_history { nil }
    software_client { 'Agave' }
    software_client_id { 3 }
  end
end
