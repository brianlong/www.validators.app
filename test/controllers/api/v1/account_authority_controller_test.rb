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
    end
  end
end
