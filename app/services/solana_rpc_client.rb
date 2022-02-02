# frozen_string_literal: true

class SolanaRpcClient
  attr_reader :cluster

  # Usage:
  # client  = SolanaRpcClient.new(cluster: 'custom_cluster') # your custom cluster
  # default = SolanaRpcClient.new.default_client # uses cluster from initializers/solana_rpc_ruby
  # testnet = SolanaRpcClient.new.testnet_client # uses testnet client
  # mainnet = SolanaRpcClient.new.mainnet_client # uses mainnet client
  #
  # mainnet.cluster # returns currently used cluster
  # mainnet.id # returns request id

  def initialize(cluster: nil)
    @cluster = cluster
  end

  def client
    @client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: @cluster
    )
  end

  def default_client
    @client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: SolanaRpcRuby.cluster
    )
  end

  def mainnet_client
    @mainnet_client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: Rails.application.credentials.solana[:mainnet_urls].first
    )
  end

  def testnet_client
    @testnet_client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: Rails.application.credentials.solana[:testnet_urls].first
    )
  end
end
