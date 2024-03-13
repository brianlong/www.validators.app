# frozen_string_literal: true

# == Schema Information
#
# Table name: ping_thing_recent_stats
#
#  id                   :bigint           not null, primary key
#  average_slot_latency :float(24)
#  fails_count          :integer
#  interval             :integer
#  max                  :float(24)
#  median               :float(24)
#  min                  :float(24)
#  min_slot_latency     :integer
#  network              :string(191)
#  num_of_records       :integer
#  p90                  :float(24)
#  p90_slot_latency     :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_ping_thing_recent_stats_on_network_and_interval  (network,interval)
#
class PingThingRecentStat < ApplicationRecord
  FIELDS_FOR_API = [
    :interval,
    :max,
    :median,
    :min,
    :network,
    :num_of_records,
    :p90,
    :average_slot_latency
  ].freeze

  INTERVALS = [5, 60].freeze #minutes

  validates :network, presence: true
  validates :network, inclusion: { in: NETWORKS }
  validates :interval, presence: true
  validates :interval, inclusion: { in: INTERVALS }

  after_update :broadcast

  def recalculate_stats
    ping_things = PingThing.for_reported_at_range_and_network(
      network,
      interval.minutes.ago,
      Time.now
    )

    ping_times = ping_things.pluck(:response_time).compact.sort

    self.update(
      median: ping_times.median,
      min: ping_times.min,
      max: ping_times.max,
      p90: ping_times.first((ping_times.count * 0.9).to_i).last,
      num_of_records: ping_times.count,
      average_slot_latency: ping_things.average_slot_latency&.round(1),
      fails_count: ping_things.where(success: false).count
    )
  end
  
  def to_builder
    Jbuilder.new do |ping_thing_recent_stat|
      ping_thing_recent_stat.(
        self,
        *FIELDS_FOR_API
      )
    end
  end

  def broadcast
    ActionCable.server.broadcast("ping_thing_recent_stat_channel", self.to_json)
  end
end
