# == Schema Information
#
# Table name: ping_time_stats
#
#  id                   :bigint           not null, primary key
#  batch_uuid           :string(255)
#  overall_min_time     :decimal(10, 3)
#  overall_max_time     :decimal(10, 3)
#  overall_average_time :decimal(10, 3)
#  observed_at          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  network              :string(255)
#
class PingTimeStat < ApplicationRecord
end
