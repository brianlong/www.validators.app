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
    stake_pool_attrs = {
      network: "testnet",
      name: "TestName",
      authority: "authority"
    }

    stake_pool = create(
      :stake_pool,
      stake_pool_attrs
    )

    validator = create(
      :validator,
      name: "Validator",
      account: "Account"
    )

    create(
      :stake_account,
      network: "testnet",
      validator: validator,
      stake_pool: stake_pool,
      delegated_stake: 5000000000000
    )

    get api_v1_stake_accounts_index_url(network: "testnet"), headers: { "Token" => @user.api_token }
    assert_response 200

    json_response = response_to_json(@response.body)

    assert_equal 1, json_response["stake_accounts"].size
    assert_equal 1, json_response["stake_pools"].size

    assert_equal "testnet", json_response["stake_accounts"].first["network"]
    assert_equal 1, json_response["total_count"]
    assert_equal 5000000000000, json_response["total_stake"]
    assert_equal stake_pool_attrs, \
      json_response["stake_pools"][0].symbolize_keys.extract!(:network, :name, :authority)
    assert_equal "TestName", json_response["stake_accounts"].first["pool_name"]
    assert_equal "Validator", json_response["stake_accounts"].first["validator_name"]
    assert_equal "Account", json_response["stake_accounts"].first["validator_account"]
    assert_equal "5,000.00", json_response["stake_accounts"].first["delegated_stake"]
    assert_equal "delegated_vote_account_address", json_response["stake_accounts"].first["delegated_vote_account_address"]
  end
end
