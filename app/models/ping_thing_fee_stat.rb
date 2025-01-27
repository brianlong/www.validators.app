# == Schema Information
#
# Table name: ping_thing_fee_stats
#
#  id                  :bigint           not null, primary key
#  average_time        :float(24)
#  fee                 :float(24)
#  median_slot_latency :float(24)
#  median_time         :float(24)
#  min_slot_latency    :float(24)
#  min_time            :float(24)
#  network             :string(191)
#  p90_slot_latency    :float(24)
#  p90_time            :float(24)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class PingThingFeeStat < ApplicationRecord

end
