# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_urls: Rails.application.credentials.solana[:testnet_urls],
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&batch_set)
            .then(&epoch_get)
            .then(&validators_cli)

puts p.inspect

ReportTowerHeightWorker.perform_async(
  epoch: p.payload[:epoch],
  batch_uuid: p.payload[:batch_uuid],
  network: p.payload[:network]
)

# Now go look in the validators_development DB
