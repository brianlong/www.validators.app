# frozen_string_literal: true

# ReportSoftwareVersiontWorker.perform_async(
#   network: 'testnet',
#   batch_uuid: '65c9083f-8f53-4873-a9f8-8f782e276d30'
# )
class ReportSoftwareVersionWorker
  include Sidekiq::Worker
  # include SolanaLogic
  include ReportLogic

  def perform(args = {})
    # byebug
    payload = {
      network: args['network'],
      batch_uuid: args['batch_uuid']
    }

    _p = Pipeline.new(200, payload)
                 .then(&report_software_versions)
  end
end
