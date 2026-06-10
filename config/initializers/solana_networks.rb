# frozen_string_literal: true

NETWORKS = %w[mainnet testnet pythnet alpenglow-community].freeze
NETWORK_URLS = {
  mainnet: Rails.application.credentials.solana[:mainnet_urls],
  testnet: Rails.application.credentials.solana[:testnet_urls],
  pythnet: Rails.application.credentials.solana[:pythnet_urls],
  "alpenglow-community": Rails.application.credentials.solana[:alpenglow_community_urls]
}.stringify_keys.freeze

NETWORKS_FOR_PING_THING = %w[mainnet testnet pythnet anzamain].freeze
