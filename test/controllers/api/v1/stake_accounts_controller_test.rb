# frozen_string_literal: true

require "test_helper"

class StakeAccountsControllerTest < ActionDispatch::IntegrationTest
  include ResponseHelper

  def setup
    @user = create(:user)

    @stake_pool_attrs = {
      network: "testnet",
      name: "TestName",
      authority: "authority",
    }

    @params = { network: "testnet" }
    @headers = { "Token" => @user.api_token }

    stake_pool = create(
      :stake_pool,
      @stake_pool_attrs
    )

    validator = create(
      :validator,
      name: "Validator",
      account: "Account"
    )

    validator_score_v1s = create(
      :validator_score_v1,
      validator_id: validator.id,
      active_stake: 100_000_000_000
    )

    create(
      :vote_account,
      validator: validator,
      account: "vote_account",
      network: "testnet"
    )

    create(
      :stake_account,
      network: "testnet",
      validator: validator,
      stake_pool: stake_pool,
      active_stake: 5_000_000_000_000,
      delegated_stake: 5_000_000_000_000,
      staker: "staker1"
    )

    create(
      :stake_account,
      network: "testnet",
      validator: validator,
      stake_pool: stake_pool,
      active_stake: 4_000_000_000_000,
      delegated_stake: 4_000_000_000_000,
      staker: "staker1"
    )

    create(
      :stake_account,
      network: "testnet",
      validator: validator,
      stake_pool: stake_pool,
      active_stake: 3_000_000_000_000,
      delegated_stake: 3_000_000_000_000,
      staker: "staker2"
    )
  end

  test "request without token should get error" do
    get api_v1_stake_accounts_index_url(@params)
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    assert_equal expected_response, response_to_json(@response.body)
  end

  test "request with token should succeed" do
    get api_v1_stake_accounts_index_url(@params), headers: @headers
    assert_response 200
  end

  test "request with no additional params should return all results" do
    get api_v1_stake_accounts_index_url(@params), headers: @headers

    assert_response 200

    json_response = response_to_json(@response.body)

    assert_equal 16, json_response["stake_accounts"].first.keys.size
  end

  test "request with page and limit params should return limited results" do
    params = @params.merge({ page: 1, per: 2 })

    get api_v1_stake_accounts_index_url(params), headers: @headers

    assert_response 200

    json_response = response_to_json(@response.body)

    assert_equal 2, json_response["stake_accounts"].size
  end

  test "request should return correct current epoch" do
    create(
      :epoch_wall_clock,
      network: "testnet",
      epoch: 99
    )
    params = @params.merge({ page: 1, per: 2 })

    get api_v1_stake_accounts_index_url(params), headers: @headers

    json_response = response_to_json(@response.body)

    assert_equal 99, json_response["current_epoch"]
  end

  test "request with grouped_by param should return correct grouped results" do
    params = @params.merge({grouped_by: "delegated_vote_accounts_address"})

    get api_v1_stake_accounts_index_url(params), headers: @headers

    assert_response 200

    json_response = response_to_json(@response.body)

    sorted_stake_accounts =
      json_response["stake_accounts"].first["Account"].sort_by do |account|
        account['active_stake']
      end

    response_stake_account = sorted_stake_accounts.first

    assert_equal 1, json_response["stake_accounts"].size
    assert_equal 16,response_stake_account.keys.size
    assert_equal "testnet", response_stake_account["network"]
    assert_equal 1, json_response["total_count"]
    assert_equal "TestName", response_stake_account["pool_name"]
    assert_equal "Validator", response_stake_account["validator_name"]
    assert_equal "Account", response_stake_account["validator_account"]
    assert_equal 3_000_000_000_000, response_stake_account["active_stake"]
    assert_equal "delegated_vote_account_address", \
      response_stake_account["delegated_vote_account_address"]
    assert_equal 100_000_000_000, \
      response_stake_account["validator_active_stake"]
  end

  test "request with additional params should return correct results" do
    params = {
      network: "testnet",
      sort_by: "stake_asc",
      filter_staker: "staker1"
    }

    get api_v1_stake_accounts_index_url(params), headers: @headers

    json_response = response_to_json(@response.body)

    # 2 stake accounts has filter_staker equal to 'staker1'
    assert_equal 2, json_response["stake_accounts"].map { |el| el["Account"] }.flatten.size
  end

  test "request as csv with token should succeed" do
    path = api_v1_stake_accounts_index_url(@params) + ".csv"
    get path, headers: @headers

    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
    assert_equal csv.size, 4

    headers = (
      StakeAccount::API_FIELDS +
      StakeAccount::API_VALIDATOR_FIELDS +
      StakeAccount::API_STAKE_POOL_FIELDS
    ).map(&:to_s)
    assert_equal csv.first, headers
  end
end
