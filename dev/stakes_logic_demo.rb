# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_logic'

include StakeLogic

# Create our initial payload with the input values
payload = {
  config_urls: Rails.application.credentials.solana[:testnet_urls],
  network: 'testnet'
}

p = Pipeline.new(200, payload)
            .then(&get_stake_accounts)

puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
puts "ERROR: #{p[:errors].inspect}"

puts "FIRST STAKE ACC: "
puts p.payload[:stake_accounts][0]

puts "STAKE ACC Count: "
puts p.payload[:stake_accounts].count
