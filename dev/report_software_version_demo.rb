include SolanaLogic
include ReportLogic

payload = {
  network: 'mainnet',
  batch_uuid: Batch.where(network: 'mainnet').last.uuid
}

p = Pipeline.new(200, payload)
             .then(&report_software_versions)

puts p.errors
