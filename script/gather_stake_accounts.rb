# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_logic'

include StakeLogic

%w[mainnet testnet].each do |network|
  config_urls = if network == 'mainnet'
    Rails.application.credentials.solana[:mainnet_urls]
  else
    Rails.application.credentials.solana[:testnet_urls]
  end

  payload = {
    config_urls: config_urls,
    network: network,
    use_token: true
  }

  p = Pipeline.new(200, payload)
              .then(&get_last_batch)
              .then(&move_current_stakes_to_history)
              .then(&get_stake_accounts)
              .then(&update_stake_accounts)
              .then(&assign_stake_pools)
              .then(&update_validator_stats)
              .then(&count_average_validators_commission)
              .then(&get_rewards)
              .then(&calculate_apy)

  puts "finished #{network} with status #{p[:code]}"
  puts "MESSAGE: #{p[:message]}"
  puts "ERROR: #{p[:errors].inspect}"
end
