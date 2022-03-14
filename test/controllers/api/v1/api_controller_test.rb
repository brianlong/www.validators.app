# frozen_string_literal: true

require "test_helper"
require "rack/cors"
require "rack/test"

# ApiControllerTest
class ApiControllerTest < ActionDispatch::IntegrationTest

  include ResponseHelper

  def setup
    @user_params = {
      username: "test",
      email: "test@test.com",
      password: "password"
    }
    @user = User.create(@user_params)

    Validator.destroy_all
  end

  test "When reaching the api \
        from origin listed in whitelist \
        should return 200" do
    get api_v1_ping_url, headers: {
      "Origin" => "http://example.com" # this origin is in whitelist
    }

    assert_response 200
    json = response_to_json(@response.body)
    assert_equal "pong", json["answer"]
  end

  test "When reaching the api \
        from foreign origin \
        should return Unauthorized" do
    get api_v1_ping_url, headers: {
      "Origin" => "http://foreign.com"
    }

    assert_response 401
    json = response_to_json(@response.body)
    assert_equal "Unauthorized", json["error"]
  end

  test "When reaching the api \
  from foreign origin but with correct token \
  should return 200" do
    get api_v1_ping_url, headers: {
      "Token" => @user.api_token,
      "Origin" => "http://foreign.com"
    }

    assert_response 200
    json = response_to_json(@response.body)
    assert_equal "pong", json["answer"]
  end

  test "GET api_v1_ping without token should get error" do
    get api_v1_ping_url
    assert_response 401
    expected_response = { "error" => "Unauthorized" }
    assert_equal expected_response, response_to_json(@response.body)
  end

  test "GET api_v1_ping with token should succeed" do
    get api_v1_ping_url, headers: { "Token" => @user.api_token }
    assert_response 200
    json = response_to_json(@response.body)
    assert_equal "pong", json["answer"]
  end

  test "GET api_v1_validator_block_history with token returns all data" do
    validator = create(:validator, :with_score, account: "Test Account")
    create(:vote_account, validator: validator)
    create(:validator_block_history, validator: validator)

    get api_v1_validator_block_history_url(
      network: "testnet",
      account: validator.account
    ), headers: { "Token" => @user.api_token }

    assert_response 200

    json_response = response_to_json(@response.body).first

    # Adjust after adding/removing attributes in json builder
    assert_equal 7, json_response.keys.size

    assert_nil json_response["epoch"]
    assert_nil json_response["batch_uuid"]
    assert_equal 1, json_response["leader_slots"]
    assert_equal 1, json_response["blocks_produced"]
    assert_equal 1, json_response["skipped_slots"]
    assert_equal "0.25", json_response["skipped_slot_percent"]
  end

  test "GET api_v1_validator_block_history with token returns only validators from chosen network and validator" do
    testnet_validator = create(:validator, account: "Test Account")
    mainnet_validator = create(:validator, :mainnet, account: "Mainnet Account")

    create(:vote_account, validator: testnet_validator)
    create(:vote_account, validator: mainnet_validator)
    create_list(:validator_block_history, 4, validator: testnet_validator)
    create_list(:validator_block_history, 3, validator: mainnet_validator)

    # Testnet
    get api_v1_validator_block_history_url(
      network: "testnet",
      account: testnet_validator.account
    ), headers: { "Token" => @user.api_token }

    json_response = response_to_json(@response.body)

    assert_response 200
    assert_equal testnet_validator.validator_block_histories.size, json_response.size

    # Mainnet
    get api_v1_validator_block_history_url(
      network: "mainnet",
      account: mainnet_validator.account
    ), headers: { "Token" => @user.api_token }

    json_response = response_to_json(@response.body)

    assert_response 200
    assert_equal mainnet_validator.validator_block_histories.size, json_response.size
  end

  test "GET api_v1_validator_block_history with token and limit returns correct number of items" do
    testnet_validator = create(:validator, account: "Test Account")
    create(:vote_account, validator: testnet_validator)
    create_list(:validator_block_history, 4, validator: testnet_validator)

    limit = 1

    get api_v1_validator_block_history_url(
      network: "testnet",
      account: testnet_validator.account,
      limit: limit
    ), headers: { "Token" => @user.api_token }
    json_response = response_to_json(@response.body)

    assert_response 200
    assert_equal limit, json_response.size
  end

  test "GET api_v1_validator_block_history with token returns ValidatorNotFound when wrong account provided" do
    get api_v1_validator_block_history_url(
      network: "testnet",
      account: "Wrong account"
    ), headers: { "Token" => @user.api_token }

    json_response = response_to_json(@response.body)
    expected_response = { "status" => "Validator Not Found" }

    assert_response 404
    assert_equal expected_response, json_response
  end
end
