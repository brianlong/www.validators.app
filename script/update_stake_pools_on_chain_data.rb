# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

NETWORKS.each do |network|
  StakePools::UpdateOnChainDataService.new(
    network: network,
    config_urls: NETWORK_URLS[network]
  ).call
end
