# frozen_string_literal: true

require "test_helper"

class StakePoolsControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
    @user = create(:user)

    @stake_pool_attrs = {
      network: "testnet",
      name: "TestName",
      authority: "authority"
    }

    @stake_pool_attrs_2 = @stake_pool_attrs.dup
    @stake_pool_attrs_2["name"] = "TestName_2"

    stake_pool = create(
      :stake_pool,
      @stake_pool_attrs
    )

    stake_pool_2 = create(
      :stake_pool,
      @stake_pool_attrs_2
    )
  end

  test "request without token should return error" do
    get api_v1_stake_pools_index_url(network: "testnet")
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "request with network should return correct results" do
    get api_v1_stake_pools_index_url(network: "testnet"), headers: { "Token" => @user.api_token }

    assert_response 200

    json_response = response_to_json(@response.body)

    assert_equal 2, json_response["stake_pools"].size
    assert_equal 18, json_response["stake_pools"].first.keys.size
  end

  test "request with network with no stake pools should return empty array" do
    get api_v1_stake_pools_index_url(network: "mainnet"), headers: { "Token" => @user.api_token }

    assert_response 200

    json_response = response_to_json(@response.body)

    assert_equal 0, json_response["stake_pools"].size
  end

  test "request as csv with network should return correct results" do
    path = api_v1_stake_pools_index_url(network: "testnet") + ".csv"
    get path, headers: { "Token" => @user.api_token }

    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
    assert_equal csv.size, 3

    headers = StakePool::API_FIELDS.map(&:to_s)
    assert_equal csv.first, headers
  end
end
