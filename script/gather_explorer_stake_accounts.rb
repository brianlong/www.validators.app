# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

network  = "mainnet"
log_path = Rails.root.join("log", "gather_explorer_stake_accounts_service_#{network}.log")
logger = Logger.new(log_path)
last_epoch = StakeAccount.where(network: network).last&.epoch.to_i

def new_epoch_detected?(network, last_epoch)
  !ExplorerStakeAccount.exists?(network: network, epoch: last_epoch)
end

# Run this script only if there are no ExplorerStakeAccounts for the last epoch
if new_epoch_detected?(network, last_epoch)
  logger.info("New epoch (#{last_epoch}) detected. service started...")
  GatherExplorerStakeAccountsService.new(
    network: network,
    config_urls: NETWORK_URLS[network],
    current_epoch: last_epoch,
    demo: false,
    logger: logger
  ).call

  CreateVoteAccountStakeHistoryService.new(network: network, epoch: last_epoch).call
else
  logger.info("No new epoch detected. Skipping...")
end
