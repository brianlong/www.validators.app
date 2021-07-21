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
            .then(&validators_cli)
            .then(&validators_get)
            .then(&vote_accounts_get)
            .then(&reduce_validator_vote_accounts)
            .then(&validators_save)
            .then(&validator_block_history_get)
            .then(&validator_block_history_save)
            .then(&log_errors)

# Now go look in the validators_development DB

# puts pipeline.inspect
puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
puts "ERROR: #{p[:errors].inspect}"
puts p.errors.backtrace
puts ''
puts 'Data for D6beCFAZeFtXoZKio6JZV1GUmJ99Nz4XhtxMePFvuJWN:'
puts ''
puts p.payload[:validators]['D6beCFAZeFtXoZKio6JZV1GUmJ99Nz4XhtxMePFvuJWN']
puts ''
puts p.payload[:vote_accounts]['D6beCFAZeFtXoZKio6JZV1GUmJ99Nz4XhtxMePFvuJWN']
puts ''
puts p.payload[:validators_reduced].count
puts ''
puts p.payload[:rpc_servers].count
puts ''
puts \
  p.payload[:validators_reduced]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
p.payload[:validator_block_history].each do |k, v|
  puts "#{k} => #{v}"
end
