# frozen_string_literal: true

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

  scope :by_network, -> (network) { where(network: network) } 

  def self.including_date(pt_time)
    query = ":t BETWEEN ping_thing_stats.time_from 
                AND DATE_ADD(ping_thing_stats.time_from, INTERVAL ping_thing_stats.interval MINUTE)"
    where(query, t: pt_time)
  end

  def recalculate
    pings = get_included_ping_things
    resp_times = pings.pluck(:response_time).compact

    self.update(
      median: resp_times.median,
      min: resp_times.min,
      max: resp_times.max,
      num_of_records: pings.count
    )
  end

  def get_included_ping_things
    PingThing.where(
      network: self.network,
      reported_at: (time_from..(time_from + interval.minutes))
    )
  end
end
