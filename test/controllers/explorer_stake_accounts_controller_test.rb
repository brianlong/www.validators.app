require "test_helper"

class ExplorerStakeAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get explorer_stake_accounts_url
    assert_response :success
  end
end
