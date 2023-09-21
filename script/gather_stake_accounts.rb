# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_logic'

include StakeLogic
NETWORKS.each do |network|
  payload = {
    config_urls: NETWORK_URLS[network],
    network: network
  }

  p = Pipeline.new(200, payload)
              .then(&get_last_batch)
              .then(&move_current_stakes_to_history)
              .then(&get_stake_accounts)
              .then(&update_stake_accounts)
              .then(&assign_stake_pools)
              .then(&update_stake_pools)
              .then(&get_rewards_from_stake_pools)
              .then(&assign_epochs)
              .then(&calculate_apy_for_accounts)
              .then(&calculate_apy_for_pools)

  TotalRewardsUpdateService.new(p.payload[:network], p.payload[:stake_accounts_active]).call

  next unless network == 'mainnet'

  # run GatherExplorerStakeAccountsService only if there is a new epoch discovered in the stake accounts
  if StakeAccount.where(network: network).last&.epoch.to_i > \
     StakeAccountHistory.where(network: network).last&.epoch.to_i
     GatherExplorerStakeAccountsService.new(
      network: network,
      config_urls: NETWORK_URLS[network],
      current_epoch: StakeAccount.where(network: network).last.epoch,
      demo: false,
      stake_accounts: p.payload[:all_stake_accounts]
    ).call
  end

  puts "finished #{network} with status #{p[:code]}"
  puts "MESSAGE: #{p[:message]}"
  puts "ERROR: #{p[:errors].inspect}"
end
