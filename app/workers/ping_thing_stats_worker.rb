# frozen_string_literal: true

class PingThingStatsWorker
  include Sidekiq::Worker

  def perform()
    %w[mainnet testnet].each do |network|
      CreatePingThingStatsService.new(network: network).call
    end
  end
end
