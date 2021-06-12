include SolanaLogic
include ReportLogic

payload = {
  network: 'testnet',
  batch_uuid: Batch.where(network: 'testnet').last.uuid
}

p = Pipeline.new(200, payload)
             .then(&report_software_versions)

puts p.errors.message