# frozen_string_literal: true

class PingThingStatsWorker
  include Sidekiq::Worker

  def perform
    NETWORKS.each do |network|
      CreatePingThingStatsService.new(network: network).call
    end
  end
end
