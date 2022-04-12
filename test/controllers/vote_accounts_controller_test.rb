# frozen_string_literal: true

require 'test_helper'

# VoteAccountsControllerTest
class VoteAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @validator = create(:validator)
    @vote_account = create(:vote_account, validator: @validator)
  end

  test 'should get show' do
    get validator_vote_account_url(
      network: 'testnet',
      account: @validator.account,
      vote_account: @vote_account.account
    )
    assert_response :success
  end
end
