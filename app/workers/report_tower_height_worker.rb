# frozen_string_literal: true

# BuildTopSkippedSlotPercentWorker.perform_async(
#   batch_uuid: '65c9083f-8f53-4873-a9f8-8f782e276d30'
# )
class ReportTowerHeightWorker
  include Sidekiq::Worker
  # include SolanaLogic
  include ReportLogic

  def perform(args = {})
    payload = {
      epoch: args['epoch'],
      network: args['network'],
      batch_uuid: args['batch_uuid'],
      name: 'report_tower_height'
    }

    _p = Pipeline.new(200, payload)
                 .then(&report_tower_height)
    # byebug
  end
end
