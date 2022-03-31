# frozen_string_literal: true

require "test_helper"

# ValidatorsControllerTest
class ValidatorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @validator = create(
      :validator, 
      :with_score,
      :with_data_center_through_validator_ip,
      network: "testnet"
    )
  end

  test "should get index" do
    get validators_url(network: "testnet")
    assert_response :success
  end

  test "should show validator" do
    validator = create(
      :validator,
      :with_score,
      :with_data_center_through_validator_ip,
      network: "testnet"
    )
    get validator_path(network: "testnet", account: validator.account)
    assert_response :success
  end

  test "should redirect to new URL format if old format given" do
    get "/validators/#{@validator.network}/#{@validator.account}"
    assert_redirected_to validator_path(account: @validator.account, network: @validator.network)
  end

  test "should redirect_to home page if validator not found" do
    get validator_url(network: "testnet", account: "notexistingaccount")

    assert_redirected_to root_url
  end
end
