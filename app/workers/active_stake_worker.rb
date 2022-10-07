# frozen_string_literal: true

class ActiveStakeWorker
  # include Sidekiq::Worker
  # include ReportLogic

  def perform(args = {})

    # payload = {
    #   network: args["network"],
    #   batch_uuid: args["batch_uuid"]
    # }

    _p = Pipeline.new(200, payload)
                 .then(&report_cluster_stats)
  end
end
