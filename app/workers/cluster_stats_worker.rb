# frozen_string_literal: true

class ClusterStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform(args = {})
    CreateClusterStatsService.new(network: args["network"], batch_uuid: args["batch_uuid"]).call
  end
end
