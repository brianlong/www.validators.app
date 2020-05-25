# frozen_string_literal: true

require 'test_helper'

# VoteAccountsControllerTest
class VoteAccountsControllerTest < ActionDispatch::IntegrationTest
  test 'should get show' do
    get vote_account_url(vote_accounts(:one))
    assert_response :success
  end
end
