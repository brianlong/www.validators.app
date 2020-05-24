# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_url: Rails.application.credentials.solana[:testnet_url],
  network: 'testnet'
}

Pipeline.new(200, payload)
        .then(&validators_get)
        .then(&vote_accounts_get)
        .then(&reduce_validator_vote_accounts)
        .then(&validators_save)
        .then(&log_errors)
