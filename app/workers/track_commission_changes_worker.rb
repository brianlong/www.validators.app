# frozen_string_literal: true

class TrackCommissionChangesWorker
  include Sidekiq::Worker

  def perform(args = {})
    current_batch = Batch.find_by(uuid: args["current_batch_uuid"])
    TrackCommissionChangesService.new(current_batch: current_batch).call
  end
end
