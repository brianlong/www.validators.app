# frozen_string_literal: true

require "test_helper"

class PingThingControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
    @user = create(:user)
    @params_sample = {
      amount: "1",
      time: "234",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      transaction_type: "transfer"
    }
  end

  test "create request without token returns error" do
    post api_v1_ping_thing_path(network: 'testnet')
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "create request with token should return 200 and save the data" do
    post api_v1_ping_thing_path(
      network: 'testnet'
    ), headers: { "Token" => @user.api_token }, params: @params_sample
    assert_response 201
    expected_response = { "status" => "created" }

    assert_equal expected_response, response_to_json(@response.body)
    assert_equal @params_sample, JSON.parse(PingThingRaw.last.raw_data).symbolize_keys
  end

  test "create request with wrong data length should return 400 error" do
    post api_v1_ping_thing_path(
      network: 'testnet'
    ), headers: { "Token" => @user.api_token }, params: {}
    assert_response 400
    expected_response = {"base"=>["Provided data length is not valid"]}

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "create_multiple request without token returns error" do
    post api_v1_ping_thing_batch_path(network: "testnet")
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "create_multiple request with token should return 200 and save the data" do
    params_batch = {
      transactions: [
        @params_sample, @params_sample
      ]
    }

    post api_v1_ping_thing_batch_path(
      network: "testnet"
    ), headers: { "Token" => @user.api_token }, params: params_batch
    assert_response 201
    expected_response = { "status" => "created" }

    assert_equal expected_response, response_to_json(@response.body)
    assert_equal params_batch[:transactions].last, JSON.parse(PingThingRaw.last.raw_data).symbolize_keys
  end

  test "create_multiple request with token should return 400 when there's too much data" do
    transactions = []
    51.times {transactions.push(@params_sample)}
    params_batch = {
      transactions: transactions
    }

    post api_v1_ping_thing_batch_path(
      network: 'testnet'
    ), headers: { "Token" => @user.api_token }, params: params_batch
    assert_response 400
    expected_response = "Too many records"

    assert_equal expected_response, response_to_json(@response.body)
  end
end
