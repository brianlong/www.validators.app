# == Schema Information
#
# Table name: ping_time_stats
#
#  id                   :bigint           not null, primary key
#  batch_uuid           :string(191)
#  network              :string(191)
#  observed_at          :datetime
#  overall_average_time :decimal(10, 3)
#  overall_max_time     :decimal(10, 3)
#  overall_min_time     :decimal(10, 3)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_ping_time_stats_on_network_and_batch_uuid  (network,batch_uuid)
#
class PingTimeStat < ApplicationRecord
end
