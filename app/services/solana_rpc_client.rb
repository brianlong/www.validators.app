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
      cluster: 'https://api.mainnet-beta.solana.com'
    )
  end

  def testnet_client
    @mainnet_client ||= SolanaRpcRuby::MethodsWrapper.new(
      cluster: 'https://api.testnet.solana.com'
    )
  end
end
