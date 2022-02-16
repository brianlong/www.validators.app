# frozen_string_literal: true

require "test_helper"

# ValidatorsControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @validator = create(:validator, :with_score, :with_score_v2, network: "testnet")
    create(:batch, network: "testnet")
  end

  test "GET with network param returns index" do
    get validators_url(network: "testnet")
    assert_response :success
  end

  test "GET with network param returns index_v2" do
    get validators_v2_url(network: "testnet")
    assert_response :success
  end

  test "GET without network param returns index_v2 with default network" do
    get validators_v2_url
    assert_response :success
  end

  test "GET with network param returns root" do
    get root_url(network: "testnet")
    assert_response :success
  end

  test "GET without network param returns root with default network" do
    get root_url
    assert_response :success
  end

  test "GET validator with account param returns validator details" do
    get validator_url(network: 'testnet', account: @validator.account)
    assert_response :success
  end

  test "GET with old validator format redirects to new URL format" do
    get "/validators/#{@validator.network}/#{@validator.account}"
    assert_redirected_to validator_path(account: @validator.account, network: @validator.network)
  end

  test "GET with incorrect account param redirects to home page" do
    get validator_url(network: "testnet", account: "notexistingaccount")

    assert_redirected_to root_url
  end
end
