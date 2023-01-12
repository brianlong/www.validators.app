# frozen_string_literal: true

getInflationRewards

require File.expand_path('../config/environment', __dir__)
include SolanaLogic

NETWORKS.each do |network|
  payload = {
    config_urls: NETWORK_URLS[network],
    network: network
  }

  test_accounts = Validator.first(5).pluck(:account)

  result = solana_client_request(
    p.payload[:config_urls],
    :get_inflation_rewards,
    params: [test_accounts]
  )

  throw result
end
