FactoryBot.define do
  factory :validator_score_stat do
    root_distance_average { 1.5 }
    root_distance_median { 1 }
    vote_distance_average { 1.5 }
    vote_distance_median { 1 }
  end
end
