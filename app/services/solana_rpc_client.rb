class SolanaRpcClient
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
      cluster: MAINNET_CLUSTER_VERSION
    )
  end

  def testnet_client
    @mainnet_client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: TESTNET_CLUSTER_VERSION
    )
  end
end
