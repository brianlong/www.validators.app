# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_recent_stats
#
#  id             :bigint           not null, primary key
#  interval       :integer
#  max            :float(24)
#  median         :float(24)
#  min            :float(24)
#  network        :string(191)
#  num_of_records :integer
#  p90            :float(24)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
#
class PingThingRecentStat < ApplicationRecord
  FIELDS_FOR_API = [
    :interval,
    :max,
    :median,
    :min,
    :network,
    :num_of_records,
    :p90
  ].freeze

  INTERVALS = [5, 60].freeze #minutes

  validates :network, presence: true
  validates :network, inclusion: { in: %w(mainnet testnet) }
  validates :interval, presence: true

  def recalculate_stats
    ping_times = PingThing.for_date_range_and_network(
      network,
      interval.minutes.ago,
      Time.now
    ).pluck(:response_time).compact.sort

    self.median = ping_times.median
    self.min = ping_times.min
    self.max = ping_times.max
    self.p90 = ping_times.first((ping_times.count * 0.9).to_i).last
    self.num_of_records = ping_times.count
  end
  
  def to_builder
    Jbuilder.new do |ping_thing_recent_stat|
      ping_thing_recent_stat.(
        self,
        *FIELDS_FOR_API
      )
    end
  end
end
