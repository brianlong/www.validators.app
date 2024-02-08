# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

require 'solana_logic'

include SolanaLogic
include ReportLogic

block_history_stat = ValidatorBlockHistoryStat.last

payload = {
  network: 'testnet',
  batch_uuid: block_history_stat.batch_uuid,
  name: 'build_skipped_slot_percent'
}

p = Pipeline.new(200, payload)
            .then(&build_skipped_slot_percent)
puts p[:errors].inspect
puts p.inspect
