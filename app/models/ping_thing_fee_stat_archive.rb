# == Schema Information
#
# Table name: ping_thing_fee_stat_archives
#
#  id                                  :bigint           not null, primary key
#  average_time                        :float(24)
#  median_slot_latency                 :float(24)
#  median_time                         :float(24)
#  min_slot_latency                    :float(24)
#  min_time                            :float(24)
#  network                             :string(191)
#  p90_slot_latency                    :float(24)
#  p90_time                            :float(24)
#  pinger_region                       :string(191)
#  priority_fee_micro_lamports_average :float(24)
#  priority_fee_percentile             :integer
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
class PingThingFeeStatArchive < ApplicationRecord
end
