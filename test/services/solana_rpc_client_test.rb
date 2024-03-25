# frozen_string_literal: true

require "test_helper"

class SolanaRpcClientTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @cluster_url = "https://api.rpcpool.com"
    @client = SolanaRpcClient.new(cluster: @cluster_url)
    @namespace = File.join("services", "solana_rpc_client")
  end

  test " #initialize sets cluster url correctly" do
    assert_equal @cluster_url, @client.cluster
  end

  test "#client returns response" do
    # No token, for privacy reason.
    vcr_cassette(@namespace, __method__) do
      method = :get_epoch_info

      response = @client.client.public_send(method)

      assert_equal 251, response.result["epoch"]
    end
  end

  test "#network_client returns correct client" do
    # No token, for privacy reason.
    vcr_cassette(@namespace, __method__) do
      rpc_client = SolanaRpcClient.new
      mainnet = rpc_client.network_client("mainnet")

      # returns same client when same network used again
      assert_equal rpc_client.network_client("mainnet"), mainnet
      # returns different client when different network used
      refute rpc_client.network_client("pythnet") == mainnet
    end
  end

  test "#network_client raises error when invalid network passed" do
    rpc_client = SolanaRpcClient.new

    assert_raise SolanaRpcClient::InvalidNetwork do
      rpc_client.network_client("invalid_network")
    end
  end
end
