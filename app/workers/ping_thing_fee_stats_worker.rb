# frozen_string_literal: true

class PingThingFeeStatsWorker
  include Sidekiq::Worker

  def perform
    NETWORKS.each do |network|
      PingThingFeeStatsService.new(network: network).call
    end
  end
end
