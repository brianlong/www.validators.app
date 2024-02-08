# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

include SolanaLogic
include ReportLogic

payload = {
  network: 'mainnet',
  batch_uuid: Batch.where(network: 'mainnet').last.uuid
}

p = Pipeline.new(200, payload)
             .then(&report_software_versions)

puts p.errors
