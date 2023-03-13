# frozen_string_literal: true

class RecalculatePingThingStatsWorker
  include Sidekiq::Worker

  def perform(args = {})
    RecalculatePingThingStatsService.new(reported_at: args["reported_at"], network: args["network"])
  end
end
