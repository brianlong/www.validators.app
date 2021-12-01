# frozen_string_literal: true
require "test_helper"

class SolanaRpcClientTest < ActiveSupport::TestCase
  include VcrHelper

  setup do
    @cluster_url = "https://api.rpcpool.com"
    @client = SolanaRpcClient.new(cluster: @cluster_url)
    @client_with_token = SolanaRpcClient.new(cluster: @cluster_url, use_token: true)
    @namespace = File.join("services", "solana_rpc_client")
  end

  test " #initialize does not use token by default" do
    assert_equal @cluster_url, @client.cluster
  end

  test "#initialize correctly add token to cluster url when use_token is true" do
    cluster_url_with_token = "https://api.rpcpool.com/rpc_token_test"
    assert_equal cluster_url_with_token, @client_with_token.cluster
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
