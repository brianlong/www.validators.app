# frozen_string_literal: true

class CreatePingThingStatsService
  include SolanaRequestsLogic

  def initialize(time_to: DateTime.now, network: "mainnet")
    @time_to = time_to
    @network = network
  end

  def call
    transactions_count = get_transactions_count.to_i
    puts transactions_count
    PingThingStat::INTERVALS.each do |interval|
      if should_add_new_stats?(interval)
        tps = if interval == 1
          get_current_tps
        else
          
        end

        ping_things = gather_ping_things(interval)
        next unless ping_things.any?

        resp_times = ping_things.pluck(:response_time).compact

        PingThingStat.create(
          network: @network,
          interval: interval,
          median: resp_times.median,
          min: resp_times.min,
          max: resp_times.max,
          time_from: @time_to - interval.minutes,
          num_of_records: ping_things.count,
          average_slot_latency: ping_things.average_slot_latency
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
    PingThing.for_reported_at_range_and_network(
      @network,
      (@time_to - interval.minutes),
      @time_to
    )
  end

  def get_transactions_count(config_urls: Rails.application.credentials.solana[:mainnet_urls])
    cli_request(
      'transaction-count',
      config_urls
    )
  end
end
