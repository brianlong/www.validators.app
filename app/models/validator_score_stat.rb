# == Schema Information
#
# Table name: validator_score_stats
#
#  id                    :bigint           not null, primary key
#  network               :string(255)
#  root_distance_average :float(24)
#  root_distance_median  :integer
#  vote_distance_average :float(24)
#  vote_distance_median  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class ValidatorScoreStat < ApplicationRecord
end
