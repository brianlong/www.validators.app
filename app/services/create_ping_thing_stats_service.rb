# frozen_string_literal: true

class CreatePingThingStatsService
  include SolanaRequestsLogic

  def initialize(time_to: DateTime.now, network: "mainnet")
    @time_to = time_to
    @network = network
    @config_urls = Rails.application.credentials.solana["#{@network}_urls".to_sym]
  end

  def call
    transactions_count = get_transactions_count.to_i rescue nil
    PingThingStat::INTERVALS.each do |interval|
      if should_add_new_stats?(interval)
        previous_stat = PingThingStat.where(network: @network, interval: interval).order(created_at: :desc).first
        tps = if previous_stat&.transactions_count&.positive? && transactions_count.positive?
          # time diff in seconds
          time_diff = DateTime.now.to_f - previous_stat.created_at.to_f
          
          (transactions_count - previous_stat.transactions_count) / time_diff rescue nil
        else
          previous_stat&.tps
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
          average_slot_latency: ping_things.average_slot_latency,
          transactions_count: transactions_count || tps * (DateTime.now.to_f - previous_stat.created_at.to_f),
          tps: tps
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
    retried = false
    begin
      tx_count = cli_request(
        "transaction-count",
        @config_urls
      )
      raise "error getting transactions count" if tx_count.nil? || tx_count.to_i <= 0
    rescue
      if !retried
        retried = true
        retry
      else
        tx_count = nil
      end
    end
    tx_count
  end
end
