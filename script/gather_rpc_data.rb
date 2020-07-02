# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/gather_rpc_data.rb
require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_url: Rails.application.credentials.solana[:testnet_url],
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&set_batch)
            .then(&validators_get)
            .then(&vote_accounts_get)
            .then(&reduce_validator_vote_accounts)
            .then(&validators_save)
            .then(&validator_block_history_get)
            .then(&validator_block_history_save)
            .then(&log_errors)

BuildSkippedSlotPercentWorker.perform_async(
  batch_uuid: p[:payload][:validator_block_history_stats]['batch_uuid']
)
BuildSkippedAfterPercentWorker.perform_async(
  batch_uuid: p[:payload][:validator_block_history_stats]['batch_uuid']
)
ChartHomePageWorker.perform_async(
  network: p[:payload][:network],
  epoch: p[:payload][:validator_block_history_stats]['epoch']
)
