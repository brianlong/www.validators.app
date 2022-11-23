# frozen_string_literal: true

class SolanaRpcClient
  class InvalidNetwork < StandardError; end

  attr_reader :cluster

  # Usage:
  # client  = SolanaRpcClient.new(cluster: 'custom_cluster') # your custom cluster
  # mainnet = SolanaRpcClient.new.network_client('mainnet') # uses cluster specific for a passed network.
  #           network_client method can receive 'mainnet','testnet' or 'pythnet' network name
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

  def network_client(network)
    raise InvalidNetwork unless ::NETWORKS.include?(network)

    network_cluster = NETWORK_URLS[network].first
    # Reset the client when the network is different from the one already initialized
    if @cluster != network_cluster
      @cluster = network_cluster
      @client = nil
    end
    client
  end
end
