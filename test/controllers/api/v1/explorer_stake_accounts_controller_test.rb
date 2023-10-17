# frozen_string_literal: true

require "test_helper"

class ExplorerStakeAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @network = "mainnet"
    @user = create(:user)
    @headers = { "Token" => @user.api_token }
    @epoch = create(:epoch_wall_clock, network: @network)
    5.times do |i|
      create(:explorer_stake_account,
        network: @network,
        stake_pubkey: "test_stake_pubkey_#{i}",
        staker: "test_staker_#{i}",
        withdrawer: "test_withdrawer_#{i}",
        delegated_vote_account_address: "test_delegated_vote_account_address_#{i}",
        epoch: @epoch.epoch
      )
    end
  end

  test "request without token should get error" do
    get api_v1_explorer_stake_accounts_path(network: @network)
    assert_response 401
    expected_response = { "error" => "Unauthorized" }

    resp = JSON.parse(@response.body)

    assert_equal expected_response, resp
  end

  test "request with token and one parameter should succeed" do
    get api_v1_explorer_stake_accounts_path(network: @network, staker: "test_staker_1"), headers: @headers
    resp = JSON.parse(@response.body)

    assert_response 200
    assert_equal 1, resp["total_count"]
  end

  test "request with token but no parameters should get error" do
    get api_v1_explorer_stake_accounts_path(network: @network), headers: @headers
    assert_response 400
    expected_response = {"status"=>"Parameter Missing - provide one of: staker, withdrawer, vote_account, stake_pubkey"}

    resp = JSON.parse(@response.body)

    assert_equal expected_response, resp
  end

  test "request csv with token should succeed" do
    get api_v1_explorer_stake_accounts_path(
      network: @network
    ) + ".csv?staker=test_staker_1", headers: @headers
    
    assert_response :success
    assert_equal "text/csv", response.content_type
    csv = CSV.parse response.body # Let raise if invalid CSV
    assert csv
  end
end
