# frozen_string_literal: true

class CreatePingThingStatsService

  INTERVALS = [1, 3, 12, 24].freeze

  def initialize(time_to: DateTime.now, network: )
    @time_to = time_to
    @network = network
  end

  def call
    INTERVALS.each do |interval|
      if should_add_new_stats?(interval)
        ping_things = gather_ping_things(interval)
        next unless ping_things.any?

        resp_times = ping_things.pluck(:response_time).compact

        p = PingThingStat.create(
          network: @network,
          interval: interval,
          median: resp_times.median,
          min: resp_times.min,
          max: resp_times.max,
          time_from: @time_to - interval.minutes,
          num_of_records: ping_things.count
        )
      end
    end
  end

  def should_add_new_stats?(interval)
    !PingThingStat.where("time_from > ?", @time_to - (interval.minutes * 2))
                  .where(network: @network, interval: interval)
                  .exists?
  end

  def gather_ping_things(interval)
    PingThing.where(
      network: @network,
      reported_at: ((@time_to - interval.minutes)..@time_to)
    )
  end
end