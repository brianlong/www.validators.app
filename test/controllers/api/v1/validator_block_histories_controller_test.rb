# frozen_string_literal: true

require "test_helper"
require "rack/cors"
require "rack/test"

# ApiControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  setup do
    @user = create(:user, :confirmed)
    @validator = create(:validator, :with_score, account: "TestAccount")
    create(:vote_account, validator: @validator)
    create(:validator_block_history, validator: @validator)
  end
  
  test "GET api_v1_validator_block_history with token returns all data" do
    get api_v1_validator_block_history_url(
      network: "testnet",
      account: @validator.account
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

  test "GET api_v1_validator_block_history returns correct data if old url is given" do
    get "/api/v1/validator_block_history/testnet/#{@validator.account}", headers: { "Token" => @user.api_token }

    json_response = response_to_json(@response.body)
    
    assert_response 200
    assert_equal @validator.validator_block_histories.size, json_response.size
  end

  test "GET api_v1_validator_block_history with token returns only validators from chosen network and validator" do
    testnet_validator = @validator
    mainnet_validator = create(:validator, :mainnet, account: "Mainnet Account")

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
    testnet_validator = @validator

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

  test 'GET SHOW | csv format should return 200' do
    path = api_v1_validator_block_history_path(
      network: "testnet", account: @validator.account
    ) + ".csv"
    get path, headers: { "Token" => @user.api_token }

    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
  end
end
