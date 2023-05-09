# write tests for AccountAuthorityController#index
# test/controllers/api/v1/account_authority_controller_test.rb
# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class AccountAuthorityControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = create(:user)
        @headers = { "Token" => @user.api_token }
        @network = "testnet"

        @validator = create(:validator, network: @network, account: "test_validator")
        @vote_account = create(
          :vote_account,
          validator: @validator,
          network: @network,
          authorized_voters: { "test_voter_key" => "test_voter_value" }
        )

        5.times do
          create(:vote_account, network: @network, authorized_voters: { "test_voter_key" => "test_voter_value" })
        end
      end

      test "#index without authorization should get unauthorized" do
        get api_v1_account_authorities_url(network: @network)
        assert_response :unauthorized
      end

      test "#index with authorized user should get success" do
        get api_v1_account_authorities_url(network: @network), headers: @headers
        assert_response :success

        resp = JSON.parse(@response.body)
        assert_equal 6, resp.count
      end

      test "#index with authorized user and validator provides correct data" do
        get api_v1_account_authorities_url(network: @network, validator: "test_validator"), headers: @headers
        assert_response :success

        resp = JSON.parse(@response.body)
        assert_equal 1, resp.count
        assert_equal @vote_account.id, resp[0]["vote_account_id"]
      end
    end
  end
end
