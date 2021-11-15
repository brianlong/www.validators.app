# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_logic'

include StakeLogic

%w[mainnet testnet].each do |network|
  if network == 'mainnet'
    config_urls = Rails.application.credentials.solana[:mainnet_urls]
  else
    config_urls = Rails.application.credentials.solana[:testnet_urls]
  end

  payload = {
    config_urls: config_urls,
    network: network
  }

  p = Pipeline.new(200, payload)
              .then(&get_last_batch)
              .then(&move_current_stakes_to_history)
              .then(&get_stake_accounts)
              .then(&save_stake_accounts)
              .then(&assign_stake_pools)

  puts "finished #{network} with status #{p[:code]}"
end
