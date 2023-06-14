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
    test "returns valid history attributes when authorization has changed" do
      vote_account = create(:vote_account, authorized_voters: { "test_voter_key" => "test_voter_value" })
      vote_account.update(authorized_voters: { "test_voter_key_2" => "test_voter_value_2" })

      va_history = vote_account.account_authority_histories.last

      assert_equal va_history.authorized_voters_before, { "test_voter_key" => "test_voter_value" }
      assert_equal va_history.authorized_voters_after, { "test_voter_key_2" => "test_voter_value_2" }
    end

    test "returns valid history attributes when new authorization has been added" do
      vote_account = create(
        :vote_account,
        authorized_voters: { "test_voter_key" => "test_voter_value" }
      )
      vote_account.update(
        authorized_voters: {
          "test_voter_key" => "test_voter_value",
          "test_voter_key_2" => "test_voter_value_2"
        }
      )

      va_history = vote_account.account_authority_histories.last
      assert_equal va_history.authorized_voters_before, {
        "test_voter_key" => "test_voter_value"
      }
      assert_equal va_history.authorized_voters_after, {
        "test_voter_key" => "test_voter_value",
        "test_voter_key_2" => "test_voter_value_2"
      }
    end

    test "returns valid history attributes when authorizations have keys changed only" do
      vote_account = create(
        :vote_account,
        authorized_voters: {
          "test_voter_key" => "test_voter_value",
          "test_voter_key_2" => "test_voter_value_2"
        }
      )
      vote_account.update(
        authorized_voters: {
          "test_voter_key_2" => "test_voter_value",
          "test_voter_key_3" => "test_voter_value_2"
        }
      )

      va_history = vote_account.account_authority_histories.last
      assert_nil va_history.authorized_voters_before
      assert_equal va_history.authorized_voters_after, {
        "test_voter_key" => "test_voter_value",
        "test_voter_key_2" => "test_voter_value_2"
      }
    end

    test "skips saving history if authorizations do not change" do
      vote_account = create(:vote_account, authorized_voters: nil)
      vote_account.update(authorized_voters: nil)

      assert_empty vote_account.account_authority_histories
    end

    test "returns valid history attributes when authorizations have changed to nil" do
      vote_account = create(
        :vote_account,
        authorized_voters: {
          "test_voter_key" => "test_voter_value",
          "test_voter_key_2" => "test_voter_value_2"
        }
      )
      vote_account.update(authorized_voters: nil)

      va_history = vote_account.account_authority_histories.last
      assert_equal va_history.authorized_voters_before, {
        "test_voter_key" => "test_voter_value",
        "test_voter_key_2" => "test_voter_value_2"
      }
      assert_nil va_history.authorized_voters_after
    end

    test "returns valid history attributes when an authorization has been removed" do
      vote_account = create(
        :vote_account,
        authorized_voters: {
          "test_voter_key" => "test_voter_value",
          "test_voter_key_2" => "test_voter_value_2"
        }
      )
      vote_account.update(
        authorized_voters: {
          "test_voter_key_2" => "test_voter_value_2"
        }
      )

      va_history = vote_account.account_authority_histories.last
      assert_equal va_history.authorized_voters_before, {
        "test_voter_key" => "test_voter_value",
        "test_voter_key_2" => "test_voter_value_2"
      }
      assert_equal va_history.authorized_voters_after, {
        "test_voter_key_2" => "test_voter_value_2"
      }
    end

    test "returns valid history attributes when authorizations have been mixed up" do
      vote_account = create(
        :vote_account,
        authorized_voters: {
          "test_voter_key" => "test_voter_value",
          "test_voter_key_2" => "test_voter_value_2"
        }
      )
      vote_account.update(
        authorized_voters: {
          "test_voter_key_2" => "test_voter_value_2",
          "test_voter_key" => "test_voter_value"
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
