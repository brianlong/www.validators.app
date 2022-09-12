# frozen_string_literal: true

class DataCenterStatsWorker
  include Sidekiq::Worker

  def perform(network)
    DataCenters::FillDataCenterStats.new(network: network).call
  end
end
