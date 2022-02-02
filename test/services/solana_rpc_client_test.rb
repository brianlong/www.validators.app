# frozen_string_literal: true
require "test_helper"

class SolanaRpcClientTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @cluster_url = "https://api.rpcpool.com"
    @client = SolanaRpcClient.new(cluster: @cluster_url)
    @client_with_token = SolanaRpcClient.new(cluster: @cluster_url)
    @namespace = File.join("services", "solana_rpc_client")
  end

  test " #initialize sets token correctly" do
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
end
