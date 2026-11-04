# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

module Blockchain
  class JsonRpcRequestTest < ActiveSupport::TestCase
    setup do
      @primary = "https://primary.example.com/secret-token"
      @backup = "https://backup.example.com/other-token"
    end

    def rpc_body(result)
      { body: { jsonrpc: "2.0", id: 1, result: result }.to_json }
    end

    test "#call sends method and params and returns result" do
      request = stub_request(:post, @primary)
                .with(body: { jsonrpc: "2.0", id: 1, method: "getLeaderSchedule", params: [100] }.to_json)
                .to_return(rpc_body({ "Leader" => [0] }))

      assert_equal({ "Leader" => [0] }, Blockchain::JsonRpcRequest.new([@primary]).call("getLeaderSchedule", [100]))
      assert_requested request
    end

    test "#call falls back to next url when result is empty or request fails" do
      stub_request(:post, @primary).to_return(rpc_body(nil))
      stub_request(:post, @backup).to_return(rpc_body("epoch" => 5))

      assert_equal({ "epoch" => 5 }, Blockchain::JsonRpcRequest.new([@primary, @backup]).call("getEpochInfo"))
    end

    test "#call returns nil and logs host without token when all urls fail" do
      stub_request(:post, @primary).to_return(body: "not json")
      logged = []

      Rails.logger.stub(:error, ->(message) { logged << message }) do
        assert_nil Blockchain::JsonRpcRequest.new(@primary).call("getEpochInfo")
      end

      assert_equal 1, logged.size
      assert_includes logged.first, "primary.example.com"
      refute_includes logged.first, "secret-token"
    end
  end
end
