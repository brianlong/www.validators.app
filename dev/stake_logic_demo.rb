# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

raise "Dev script can't be executed on production" if Rails.env.production?

require 'stake_logic'

include StakeLogic

# Create our initial payload with the input values
payload = {
  config_urls: Rails.application.credentials.solana[:testnet_urls],
  network: 'testnet'
}
start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
p = Pipeline.new(200, payload)
            .then(&get_last_batch)
            .then(&move_current_stakes_to_history)
            .then(&get_stake_accounts)
            .then(&update_stake_accounts)
            .then(&assign_stake_pools)
            .then(&update_stake_pools)
            .then(&get_rewards_from_stake_pools)
            .then(&assign_epochs)
            .then(&get_validator_history_for_lido)
            .then(&calculate_apy_for_accounts)
            .then(&calculate_apy_for_pools)

end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

duration = end_time - start_time

puts "CODE: #{p[:code]}"
puts "MESSAGE: #{p[:message]}"
if p[:errors]
  puts "ERROR: #{p[:errors].inspect}"
  puts p[:errors].backtrace
end
puts "DURATION: #{duration}"

puts "\nFIRST STAKE ACC: "
puts p.payload[:stake_accounts][0]

puts "\nSTAKE ACC COUNT: "
puts p.payload[:stake_accounts].count

puts "\nFIRST DB STAKE ACCOUNT: "
puts StakeAccount.first.inspect

puts "\n DB STAKE ACCOUNT COUNT: "
puts StakeAccount.count
