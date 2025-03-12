# frozen_string_literal: true

require "test_helper"
require "rack/cors"
require "rack/test"

module Api
  module V1
    class VoteControllerTest < ActionDispatch::IntegrationTest
      include ResponseHelper

      setup do
        @user = create(:user)
        @headers = { "Token" => @user.api_token }
        @network = "mainnet"

        @block = create(:mainnet_block)
        create_list(:mainnet_transaction, 500, block: @block)
      end

      test "GET api_v1_last_blocks without token returns error" do
        get api_v1_last_blocks_path(@network)
        assert_response 401
        expected_response = { "error" => "Unauthorized" }

        assert_equal expected_response, response_to_json(@response.body)
      end

      test "GET api_v1_block_votes without token returns error" do
        get api_v1_block_votes_path(@network, @block.blockhash)
        assert_response 401
        expected_response = { "error" => "Unauthorized" }

        assert_equal expected_response, response_to_json(@response.body)
      end

      test "GET api_v1_last_blocks with token returns 200" do
        get api_v1_last_blocks_path(@network), headers: @headers
        assert_response 200

        assert_equal 1, JSON.parse(@response.body).size
        assert_equal @block.blockhash, JSON.parse(@response.body).first["blockhash"]
      end

      test "GET api_v1_block_votes with token returns 200" do
        get api_v1_block_votes_path(@network, @block.blockhash), headers: @headers
        assert_response 200

        assert_equal 500, JSON.parse(@response.body)["transactions"].size
        assert_equal @block.blockhash, JSON.parse(@response.body)["blockhash"]
      end

      test "GET api_v1_block_votes with token limit and page returns 200" do
        get api_v1_block_votes_path(@network, @block.blockhash, limit: 100, page: 2), headers: @headers
        assert_response 200

        assert_equal 100, JSON.parse(@response.body)["transactions"].size
      end
    end
  end
end
