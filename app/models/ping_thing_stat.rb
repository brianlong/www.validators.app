# == Schema Information
#
# Table name: ping_thing_stats
#
#  id             :bigint           not null, primary key
#  interval       :integer
#  max            :float(24)
#  median         :float(24)
#  min            :float(24)
#  network        :string(191)
#  num_of_records :integer
#  time_from      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class PingThingStat < ApplicationRecord
end
