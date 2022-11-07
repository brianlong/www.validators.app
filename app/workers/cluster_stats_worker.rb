# frozen_string_literal: true

class ClusterStatsWorker
  include Sidekiq::Worker

  def perform(args = {})
    CreateClusterStatsService.new(network: args["network"], batch_uuid: args["batch_uuid"]).call
  end
end
