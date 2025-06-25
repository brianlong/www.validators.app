# frozen_string_literal: true

class PingThingFeeStatsWorker
  include Sidekiq::Worker

  def perform
    NETWORKS_FOR_PING_THING.each do |network|
      PingThingFeeStatsService.new(network: network).call
    end
  end
end
