# frozen_string_literal: true

class RecalculatePingThingStatsService
  def initialize(reported_at:, network: "mainnet")
    @reported_at = reported_at
    @network = network
  end

  def call
    stats = PingThingStat.by_network(@network).between_time_range(@reported_at)
    stats.each(&:recalculate)

    fee_stats = PingThingFeeStat.by_network(@network).between_time_range(@reported_at)
    fee_stats.each(&:recalculate)
  end
end

