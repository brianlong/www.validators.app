#frozen_string_literal: true

class PingThingUserStatsWorker
  include Sidekiq::Worker

  def perform(network = "mainnet")
    PingThingUserStat::INTERVALS.each do |interval|
      PingThingUserStatsService.new(network: network, interval: interval).call
    end
  end
end
