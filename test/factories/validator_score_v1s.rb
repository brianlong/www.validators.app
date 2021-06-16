# frozen_string_literal: true

FactoryBot.define do
  factory :validator_score_v1 do
    validator
    active_stake { rand 10_000 }
    root_distance_history { [1, 2, 3, 4, 5] }
    vote_distance_history { [5, 4, 3, 2, 1] }
    skipped_vote_history { [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9] }
    skipped_slot_history { [0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1] }
  end
end
