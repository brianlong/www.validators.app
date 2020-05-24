# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_url: Rails.application.credentials.solana[:testnet_url],
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&validators_get)
            .then(&vote_accounts_get)
            .then(&reduce_validator_vote_accounts)
            .then(&validators_save)
# .then(&log_errors)

# Now go look in the validators_development DB

# puts pipeline.inspect
puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
puts "ERROR: #{p[:errors].inspect}"
puts ''
puts 'Data for 71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B:'
puts ''
puts p.payload[:validators]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
puts p.payload[:vote_accounts]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
puts \
  p.payload[:validators_reduced]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
