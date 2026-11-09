# frozen_string_literal: true

module XNotifications
  class EpochReportsWorker
    include Sidekiq::Worker
    sidekiq_options retry: 0, dead: false, lock: :until_executed

    def perform(args = {})
      CommissionReportService.new(network: args["network"]).call
      StakePoolReportService.new(network: args["network"]).call
    end
  end
end
