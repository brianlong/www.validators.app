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
      :vote_account,
      validator: validator,
      account: 'vote_account',
      network: 'testnet'
    )

    create(
      :stake_account,
      network: "testnet",
      validator: validator,
      stake_pool: stake_pool,
      active_stake: 5000000000000,
      delegated_stake: 5000000000000
    )

    get api_v1_stake_accounts_index_url(network: "testnet"), headers: { "Token" => @user.api_token }
    assert_response 200

    json_response = response_to_json(@response.body)

    response_stake_account = json_response["stake_accounts"][0]['Account'][0]

    assert_equal 1, json_response["stake_accounts"].size
    assert_equal 1, json_response["stake_pools"].size

    assert_equal "testnet", response_stake_account["network"]
    assert_equal 1, json_response["total_count"]
    assert_equal 5000000000000, json_response["total_stake"]
    assert_equal stake_pool_attrs, \
      json_response["stake_pools"][0].symbolize_keys.extract!(:network, :name, :authority)
    assert_equal "TestName", response_stake_account["pool_name"]
    assert_equal "Validator", response_stake_account["validator_name"]
    assert_equal "Account", response_stake_account["validator_account"]
    assert_equal 5000000000000, response_stake_account["active_stake"]
    assert_equal "delegated_vote_account_address", \
      response_stake_account["delegated_vote_account_address"]
  end
end
