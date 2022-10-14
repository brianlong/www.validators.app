# frozen_string_literal: true

class ActiveStakeWorker
  include StakeStatsLogic

  def perform(network:, batch_uuid: )
    CreateClusterStatsService.new(network: network, batch_uuid: batch_uuid).call
  end
end
