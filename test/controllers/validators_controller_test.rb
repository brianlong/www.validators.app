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

  test "index sorted by stake shows adversarial and offline superminority lines" do
    batch = create(:batch, network: "testnet")
    @validator.score.update!(active_stake: 10)
    create(:validator_history, network: "testnet", batch_uuid: batch.uuid,
           validator: @validator, account: @validator.account, active_stake: 10)
    [90, 70, 50, 40, 20].each do |stake|
      v = create(:validator, :with_score, network: "testnet")
      v.score.update!(active_stake: stake)
      create(:validator_history, network: "testnet", batch_uuid: batch.uuid,
             validator: v, account: v.account, active_stake: stake)
    end

    get validators_path(network: "testnet", order: "stake")

    assert_response :success
    assert_includes response.body, "Cumulative stake above (20&percnt;) can compromise network safety"
    assert_includes response.body, "Cumulative stake above (40&percnt;) can halt the network if offline"
    assert_operator response.body.index("(20&percnt;)"), :<, response.body.index("(40&percnt;)")
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
