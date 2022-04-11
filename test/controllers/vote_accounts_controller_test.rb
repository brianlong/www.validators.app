# frozen_string_literal: true

require 'test_helper'

# VoteAccountsControllerTest
class VoteAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vote_account = vote_accounts(:one)
  end

  test 'should get show' do
    get vote_account_url(
      network: 'testnet',
      account: @vote_account.account,
      validator_id: @vote_account.validator_id
    )
    assert_response :success
  end
end
