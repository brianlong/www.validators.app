# frozen_string_literal: true

NETWORKS = %w[mainnet testnet].freeze
ALPENGLOW_NETWORKS = %w[mainnet testnet].freeze
NETWORK_URLS = {
  mainnet: Rails.application.credentials.solana[:mainnet_urls],
  testnet: Rails.application.credentials.solana[:testnet_urls]
}.stringify_keys.freeze

NETWORKS_FOR_PING_THING = %w[mainnet testnet anzamain].freeze
