# frozen_string_literal: true

# ReportClusterStatsWorker.perform_async(
#   network: 'testnet',
#   batch_uuid: '65c9083f-8f53-4873-a9f8-8f782e276d30'
# )
class ReportClusterStatsWorker
  include Sidekiq::Worker
  include ReportLogic

  def perform(args = {})
    # byebug
    payload = {
      network: args["network"],
      batch_uuid: args['batch_uuid']
    }

    _p = Pipeline.new(200, payload)
                 .then(&report_cluster_stats)
  end
end
