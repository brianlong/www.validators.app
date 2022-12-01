# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'solana_logic'

include SolanaLogic

# Create our initial payload with the input values
payload = {
  config_urls: Rails.application.credentials.solana[:testnet_urls],
  network: 'testnet'
}

puts Rails.application.credentials.solana[:testnet_urls]

p = Pipeline.new(200, payload)
            .then(&batch_set)
            .then(&batch_touch)
            .then(&epoch_get)
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
# puts p.errors.backtrace
puts ''
puts 'Data for 9pZZWsvdWsYiWSrt13MrxCuSigDcKfBzmc58HBfoZuwn:'
puts ''
puts p.payload[:validators]['9pZZWsvdWsYiWSrt13MrxCuSigDcKfBzmc58HBfoZuwn']
puts ''
puts p.payload[:vote_accounts]['9pZZWsvdWsYiWSrt13MrxCuSigDcKfBzmc58HBfoZuwn']
puts ''
puts p.payload[:validators_reduced].count
puts ''
puts \
  p.payload[:validators_reduced]['71bhKKL89U3dNHzuZVZ7KarqV6XtHEgjXjvJTsguD11B']
puts ''
vh = ValidatorHistory.where(network: p.payload[:network], batch_uuid: p.payload[:batch_uuid], account: '9pZZWsvdWsYiWSrt13MrxCuSigDcKfBzmc58HBfoZuwn')
puts vh.inspect
# p.payload[:validator_block_history].each do |k, v|
#   puts "#{k} => #{v}"
# end
