# frozen_string_literal: true

class SolanaRpcClient
  attr_reader :cluster

  def initialize(cluster: nil, use_token: false)
    token = Rails.application.credentials.dig(:solana, :rpc_token)
    cluster_url = use_token ? "#{cluster}/#{token}" : cluster

    @cluster = cluster_url
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
      cluster: MAINNET_CLUSTER_VERSION
    )
  end

  def testnet_client
    @mainnet_client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: TESTNET_CLUSTER_VERSION
    )
  end
end
