# frozen_string_literal: true

class ActiveStakeWorker
  include Sidekiq::Worker

  def perform(args = {})
    CreateClusterStatsService.new(network: args["network"], batch_uuid: args["batch_uuid"]).call
  end
end
