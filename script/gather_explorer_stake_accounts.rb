#frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

network  = "mainnet"

last_epoch = StakeAccount.where(network: network).last&.epoch.to_i

# Run this script only if there are no ExplorerStakeAccounts for the last epoch
unless ExplorerStakeAccount.exists?(network: network, epoch: last_epoch)
  GatherExplorerStakeAccountsService.new(
    network: network,
    config_urls: NETWORK_URLS[network],
    current_epoch: last_epoch,
    demo: false,
  ).call
end
