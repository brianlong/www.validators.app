# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_logic'

include StakeLogic
NETWORKS.each do |network|
  unless StakePool.where(network: network).exists?
    puts "Skipping #{network}, because there are no StakePools available."
    next
  end

  payload = {
    config_urls: NETWORK_URLS[network],
    network: network
  }

  p = Pipeline.new(200, payload)
              .then(&check_current_epoch)
              .then(&get_last_batch)
              .then(&get_stake_accounts)
              .then(&move_current_stakes_to_history)
              .then(&update_stake_accounts)
              .then(&assign_stake_pools)
              .then(&update_stake_pools)
              .then(&get_rewards_from_stake_pools)
              .then(&assign_epochs)
              .then(&calculate_apy_for_accounts)
              .then(&calculate_apy_for_pools)

  TotalRewardsUpdateService.new(p.payload[:network], p.payload[:stake_accounts_active]).call

  puts "finished #{network} with status #{p[:code]}"
  puts "MESSAGE: #{p[:message]}"
  puts "ERROR: #{p[:errors].inspect}"
end
