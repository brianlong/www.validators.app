# frozen_string_literal: true

require "test_helper"

class PingThingControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
    @user = create(:user)
    @params_sample = {
      amount: "1",
      application: "mango",
      commitment_level: "finalized",
      signature: "5zxrAiJcBkAHpDtY4d3hf8YVgKjENpjUUEYYYH2cCbRozo8BiyTe6c7WtBqp6Rw2bkz7b5Vxkbi9avR7BV9J1a6s",
      success: "true",
      time: "234",
      transaction_type: "transfer"
    }
  end

  test "POST api_v1_ping_thing without token returns error" do
    post api_v1_ping_thing_path(network: 'testnet')
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "POST api_v1_ping_thing with token returns 200 and saves the data" do
    post api_v1_ping_thing_path(
      network: "testnet"
    ), headers: { "Token" => @user.api_token }, params: @params_sample
    assert_response 201
    expected_response = { "status" => "created" }

    assert_equal expected_response, response_to_json(@response.body)
    assert_equal @params_sample, JSON.parse(PingThingRaw.last.raw_data).symbolize_keys
  end

  test "POST api_v1_ping_thing with wrong data length returns 400 error" do
    post api_v1_ping_thing_path(
      network: "testnet"
    ), headers: { "Token" => @user.api_token }, params: {}
    assert_response 400
    expected_response = {"base"=>["Provided data length is not valid"]}

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "GET api_v1_ping_things with correct network returns pings from chosen network" do
    create(:ping_thing, :testnet)
    create(:ping_thing, :mainnet)

    get api_v1_ping_things_path(network: "testnet"), headers: { "Token" => @user.api_token }

    assert_response 200
    json = response_to_json(@response.body)
    assert_equal 1, json.size
  end

  test "GET api_v1_ping_things with limit present returns pings for chosen limit" do
    3.times do
      create(:ping_thing, :testnet)
    end

    get api_v1_ping_things_path(network: "testnet", limit: 2), headers: { "Token" => @user.api_token }

    assert_response 200
    assert_equal 2, response_to_json(@response.body).size
  end

  test "GET api_v1_ping_things with limit returns correct pings starting from the newest" do
    create(:ping_thing, :testnet, response_time: 123)

    get api_v1_ping_things_path(network: "testnet", limit: 1), headers: { "Token" => @user.api_token }

    json = response_to_json(@response.body)
    assert_equal 123, json.first["response_time"]
  end
end
