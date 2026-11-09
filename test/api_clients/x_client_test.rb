# frozen_string_literal: true

require "test_helper"
require "webmock/minitest"

module ApiClients
  class XClientTest < ActiveSupport::TestCase
    setup do
      @credentials = {
        api_key: "api-key",
        api_secret: "api-secret",
        access_token: "access-token",
        access_token_secret: "access-token-secret"
      }
    end

    test "#configured? returns false when credentials are missing" do
      refute XClient.new(credentials: nil).configured?
      refute XClient.new(credentials: @credentials.except(:api_secret)).configured?
    end

    test "#configured? returns true when all credentials are present" do
      assert XClient.new(credentials: @credentials).configured?
    end

    test "#create_post sends signed request and returns post id" do
      request = stub_request(:post, XClient::API_URL)
                .with(
                  body: { text: "hello", reply: { in_reply_to_tweet_id: "123" } }.to_json,
                  headers: { "Content-Type" => "application/json" }
                ) { |req| req.headers["Authorization"].match?(/\AOAuth .*oauth_signature="[^"]+"/) }
                .to_return(status: 201, body: { data: { id: "456", text: "hello" } }.to_json)

      assert_equal "456", XClient.new(credentials: @credentials).create_post(text: "hello", in_reply_to: "123")
      assert_requested request
    end

    test "#create_post raises error when response is not successful" do
      stub_request(:post, XClient::API_URL).to_return(status: 402, body: { title: "CreditsDepleted" }.to_json)

      assert_raises(XClient::XResponseError) do
        XClient.new(credentials: @credentials).create_post(text: "hello")
      end
    end
  end
end
