# frozen_string_literal: true

require 'test_helper'

# VoteAccountsControllerTest
class VoteAccountsControllerTest < ActionDispatch::IntegrationTest
  test 'should get show' do
    get vote_account_url(
      network: 'testnet',
      account: vote_accounts(:one).account
    )
    assert_response :success
  end
end
