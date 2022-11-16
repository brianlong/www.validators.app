# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'stake_logic'

include StakeLogic
NETWORKS.each do |network|
  payload = {
    config_urls: Rails.application.credentials.solana["#{network}_urls".to_sym],
    network: network
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
              .then(&assign_epochs)
              .then(&get_validator_history_for_lido)
              .then(&calculate_apy_for_accounts)
              .then(&calculate_apy_for_pools)

  puts "finished #{network} with status #{p[:code]}"
  puts "MESSAGE: #{p[:message]}"
  puts "ERROR: #{p[:errors].inspect}"
end
