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
        create :account_authority_history

        get api_v1_account_authorities_url(network: @network), headers: @headers
        response_body = JSON.parse response.body

        assert_equal "withdrawer", response_body["authority_changes"][0]["authorized_withdrawer_before"]
        assert_equal "newwithdrawer", response_body["authority_changes"][0]["authorized_withdrawer_after"]
        assert_equal 1, response_body["total_count"]
      end
    end
  end
end
