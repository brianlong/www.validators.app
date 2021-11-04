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
            .then(&get_last_batch)
            .then(&move_current_stakes_to_history)
            .then(&get_stake_accounts)
            .then(&save_stake_accounts)

puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
puts "ERROR: #{p[:errors].inspect}"

puts "FIRST STAKE ACC: "
puts p.payload[:stake_accounts][0]

puts "STAKE ACC Count: "
puts p.payload[:stake_accounts].count

f = File.open('stake_accounts.json', 'w')
f.write p.payload[:stake_accounts].to_json
