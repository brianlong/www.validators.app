# frozen_string_literal: true

# BuildTopSkippedSlotPercentWorker.perform_async(
#   batch_uuid: '65c9083f-8f53-4873-a9f8-8f782e276d30'
# )
class BuildSkippedSlotPercentWorker
  include Sidekiq::Worker
  # include SolanaLogic
  include ReportLogic

  def perform(args = {})
    payload = {
      network: 'testnet',
      batch_uuid: args['batch_uuid'],
      name: 'build_skipped_slot_percent'
    }

    Pipeline.new(200, payload)
            .then(&build_skipped_slot_percent)
  end
end
