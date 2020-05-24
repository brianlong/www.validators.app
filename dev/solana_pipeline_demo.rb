# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_url: Rails.application.credentials.solana[:testnet_url],
  network: 'testnet'
}

pipeline = Pipeline.new(200, payload)
                   .then(&validators_get)
                   .then(&vote_accounts_get)
                   .then(&reduce_validator_vote_accounts)
                   .then(&validators_save)

# Now go look in the validators_development DB

# puts pipeline.inspect
puts "CODE: #{pipeline[:code]}"
puts "MESSAGE: #{pipeline[:message]}"
puts "ERROR: #{pipeline[:errors].inspect}"
puts ''
puts 'Data for 71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B:'
puts ''
puts \
  pipeline.payload[:validators]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
puts pipeline.payload[:vote_accounts]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
puts \
  pipeline.payload[:validators_reduced]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
# pipeline.payload[:validators].each do |_validator|
#   puts pipeline.payload[:gossip]['gossip']
# end
