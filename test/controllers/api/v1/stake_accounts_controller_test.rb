# frozen_string_literal: true

require "test_helper"

class StakeAccountsControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
    @user = create(:user)
  end

  test "request without token should get error" do
    get api_v1_stake_accounts_index_url(network: "testnet")
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "request with token should succeed" do
    get api_v1_stake_accounts_index_url(network: "testnet"), headers: { "Token" => @user.api_token }
    assert_response 200
  end

  test "request should return correct results" do
    create(:stake_account, network: "testnet")

    stake_pool_attrs = {
      network: "testnet",
      name: "TestName",
      authority: "authority"
    }
    
    create(
      :stake_pool,
      stake_pool_attrs
    )
    get api_v1_stake_accounts_index_url(network: "testnet"), headers: { "Token" => @user.api_token }
    assert_response 200

    assert_equal 1, response_to_json(@response.body)["stake_accounts"].size
    assert_equal "testnet", response_to_json(@response.body)["stake_accounts"].first["network"]
    assert_equal 1, response_to_json(@response.body)["total_count"]
    assert_equal 200, response_to_json(@response.body)["total_stake"]
    assert_equal 1, response_to_json(@response.body)["stake_pools"].size
    assert_equal stake_pool_attrs, \
      response_to_json(@response.body)["stake_pools"][0].symbolize_keys.extract!(:network, :name, :authority)
  end
end