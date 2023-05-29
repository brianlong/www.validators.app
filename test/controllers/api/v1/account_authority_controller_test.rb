# write tests for AccountAuthorityController#index
# test/controllers/api/v1/account_authority_controller_test.rb
# frozen_string_literal: true

require "test_helper"

module Api
  module V1
    class AccountAuthorityControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = create(:user)
        @headers = { "Token" => @user.api_token }
        @network = "testnet"
      end

      test "#index without authorization should get unauthorized" do
        get api_v1_account_authorities_url(network: @network)
        assert_response :unauthorized
      end

      test "#index with authorized user should get success" do
        get api_v1_account_authorities_url(network: @network), headers: @headers
        assert_response :success
      end

      test "#index returns valid response with total_count value" do
        history = create :account_authority_history

        get api_v1_account_authorities_url(network: @network), headers: @headers
        response_body = JSON.parse response.body

        assert(response_body, {
          "authority_changes" => [
            {
              "authorized_withdrawer_before" => "withdrawer",
              "authorized_withdrawer_after" => nil,
              "authorized_voters_before" => nil,
              "authorized_voters_after" => nil,
              "network" => "testnet",
              "created_at" => history.created_at.as_json,
              "vote_account_address" => "Test Account"
            }
          ],
          "total_count" => 1
        })
      end
    end
  end
end
