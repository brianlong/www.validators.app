# frozen_string_literal: true

# BuildTopSkippedSlotPercentWorker.perform_async(
#   batch_uuid: '65c9083f-8f53-4873-a9f8-8f782e276d30'
# )
class ChartHomePageWorker
  include Sidekiq::Worker
  # include SolanaLogic
  include ReportLogic

  def perform(args = {})
    payload = {
      network: args['network'],
      epoch: args['epoch'],
      name: 'chart_home_page'
    }

    Pipeline.new(200, payload)
            .then(&chart_home_page)
  end
end
