# == Schema Information
#
# Table name: asn_stats
#
#  id                              :bigint           not null, primary key
#  active_stake                    :float(24)
#  calculated_at                   :datetime
#  data_centers                    :text(65535)
#  network                         :string(191)
#  population                      :integer
#  traits_autonomous_system_number :integer
#  vote_distance_moving_average    :float(24)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
class AsnStat < ApplicationRecord
  serialize :data_centers, JSON
end
