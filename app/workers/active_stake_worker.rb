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
                 .then(&update_total_active_stake)
  end
end
