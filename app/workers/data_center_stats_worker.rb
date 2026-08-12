# frozen_string_literal: true

class DataCenterStatsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, dead: false

  def perform(args = {})
    DataCenters::FillDataCenterStats.new(network: args["network"], batch_uuid: args["batch_uuid"]).call
  end
end
