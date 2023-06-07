require 'test_helper'

class VoteAccountTest < ActiveSupport::TestCase
  test "scope for_api returs vote_accounts specified fields" do
    assert_equal VoteAccount::FIELDS_FOR_API.map(&:to_s), VoteAccount.for_api.first.attributes.keys
  end

  test "authorized_withdrawer" do
    vote_account = create(:vote_account, authorized_withdrawer: "test_withdrawer")
    vote_account.update(authorized_withdrawer: "test_withdrawer_2")

    va_histories = vote_account.account_authority_histories

    assert_equal va_histories.last.authorized_withdrawer_before, "test_withdrawer"
    assert_equal va_histories.last.authorized_withdrawer_after, "test_withdrawer_2"
  end

  class AuthorizedVotersTests < ActiveSupport::TestCase
    test "returns valid attributes during the update with a single key" do
      vote_account = create(:vote_account, authorized_voters: { "test_voter_key" => "test_voter_value" })
      vote_account.update(authorized_voters: { "test_voter_key_2" => "test_voter_value_2" })

      va_history = vote_account.account_authority_histories.last

      assert_equal va_history.authorized_voters_before, { "test_voter_key" => "test_voter_value" }
      assert_equal va_history.authorized_voters_after, { "test_voter_key_2" => "test_voter_value_2" }
    end

    test "returns valid attributes during the update with multiple keys" do
      vote_account = create(
        :vote_account,
        authorized_voters: { "test_voter_key" => "test_voter_value" }
      )
      vote_account.update(
        authorized_voters: {
          "test_voter_key_2" => "test_voter_value_2",
          "test_voter_key_3" => "test_voter_value_3"
        }
      )

      va_history = vote_account.account_authority_histories.last
      assert_equal va_history.authorized_voters_before, {
        "test_voter_key" => "test_voter_value"
      }
      assert_equal va_history.authorized_voters_after, {
        "test_voter_key_2" => "test_voter_value_2",
        "test_voter_key_3" => "test_voter_value_3"
      }
    end

    test "returns valid attributes during the update with multiple keys but different keys only" do
      vote_account = create(
        :vote_account,
        authorized_voters: {
          "test_voter_key" => "test_voter_value",
          "test_voter_key_2" => "test_voter_value_2"
        }
      )

      vote_account.update(
        authorized_voters: {
          "test_voter_key_3" => "test_voter_value",
          "test_voter_key_4" => "test_voter_value_2"
        }
      )

      va_history = vote_account.account_authority_histories.last
      assert_nil va_history.authorized_voters_before
      assert_equal va_history.authorized_voters_after, {
        "test_voter_key" => "test_voter_value",
        "test_voter_key_2" => "test_voter_value_2"
      }
    end
  end
end
