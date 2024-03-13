# frozen_string_literal: true

require "test_helper"

# ValidatorsControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      network: "testnet"
    )
  end

  test "index returns 200" do
    get validators_path(network: "testnet")

    assert_response :success
  end

  test "trent_mode returns 200" do
    get trent_mode_path(network: "testnet")

    assert_response :success
  end

  test "show returns 200" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      network: "testnet"
    )
    get validator_path(network: "testnet", account: validator.account)
    assert_response :success
  end

  test "redirects to new URL format if old format given" do
    get "/validators/#{@validator.network}/#{@validator.account}"
    assert_redirected_to validator_path(account: @validator.account, network: @validator.network)
  end

  test "redirects to home page if validator not found" do
    get validator_url(network: "testnet", account: "notexistingaccount")

    assert_redirected_to root_url
  end

  test "index returns 200 if there are no validators" do
    get validators_path(network: "testnet")
    assert_response :success
  end

  test "trent_mode returns 200 if there are no validators" do
    get trent_mode_path(network: "testnet")
    assert_response :success
  end

  test "index returns 200 with watchlist param and signed in user" do
    user = create(:user, :confirmed)
    sign_in user

    get validators_path(network: "testnet", watchlist: true)

    assert_response :success
  end

  test "index redirects to sign up page for watchlist param and no signed in user" do
    get validators_path(network: "testnet", watchlist: true)

    assert_redirected_to new_user_registration_path
    assert_match "You need to create an account first.", flash[:warning]
  end
end
