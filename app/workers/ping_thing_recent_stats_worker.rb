# frozen_string_literal: true

class PingThingRecentStatsWorker
  include Sidekiq::Worker

  def perform(network = "mainnet")
    PingThingRecentStat::INTERVALS.each do |interval|
      stat = PingThingRecentStat.find_or_create_by(interval: interval, network: network)
      stat.recalculate_stats
    end
  end
end
