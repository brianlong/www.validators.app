# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_stats
#
#  id                   :bigint           not null, primary key
#  average_slot_latency :integer
#  interval             :integer
#  max                  :float(24)
#  median               :float(24)
#  min                  :float(24)
#  network              :string(191)
#  num_of_records       :integer
#  time_from            :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_ping_thing_stats_on_network_and_interval  (network,interval)
#
class PingThingStat < ApplicationRecord
  FIELDS_FOR_API = [
    :interval,
    :max,
    :median,
    :min,
    :network,
    :num_of_records,
    :time_from,
    :average_slot_latency
  ].freeze

  INTERVALS = [1, 3, 12, 24, 168].freeze #minutes

  validates :network, presence: true
  validates :network, inclusion: { in: %w(mainnet testnet) }
  validates :interval, presence: true
  validates :interval, inclusion: { in: INTERVALS }

  scope :by_network, -> (network) { where(network: network) }

  after_create :broadcast

  def self.between_time_range(pt_time)
    query = ":t BETWEEN ping_thing_stats.time_from 
                AND DATE_ADD(ping_thing_stats.time_from, INTERVAL ping_thing_stats.interval MINUTE)"
    where(query, t: pt_time)
  end

  def recalculate
    resp_times = PingThing.for_reported_at_range_and_network(
      network,
      time_from,
      (time_from + interval.minutes)
    ).pluck(:response_time).compact

    self.update(
      median: resp_times.median,
      min: resp_times.min,
      max: resp_times.max,
      num_of_records: resp_times.count
    )
  end

  def broadcast
    ActionCable.server.broadcast("ping_thing_stat_channel", self.to_json)
  end
  
  def to_builder
    Jbuilder.new do |ping_thing_stat|
      ping_thing_stat.(
        self,
        *FIELDS_FOR_API
      )
    end
  end
end
