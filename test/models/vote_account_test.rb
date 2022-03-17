require 'test_helper'

class VoteAccountTest < ActiveSupport::TestCase
  setup do
    @vote_account = create(:vote_account)
  end

  test "scope for_api returs vote_accounts specified fields" do
    assert_equal VoteAccount::FIELDS_FOR_API.map(&:to_s), VoteAccount.for_api.first.attributes.keys
  end
end
