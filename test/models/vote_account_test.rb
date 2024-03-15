#frozen_string_literal: true

require "test_helper"
require "sidekiq/testing"


class VoteAccountTest < ActiveSupport::TestCase
  test "scope for_api returs vote_accounts specified fields" do
    v = create(:validator)
    va = create(:vote_account, validator: v)
    assert_equal VoteAccount::FIELDS_FOR_API.map(&:to_s), VoteAccount.for_api.first.attributes.keys
  end

  test "authorized_withdrawer" do
    vote_account = create(:vote_account, authorized_withdrawer: "test_withdrawer")
    vote_account.update(authorized_withdrawer: "test_withdrawer_2")

    va_histories = vote_account.account_authority_histories

    assert_equal va_histories.last.authorized_withdrawer_before, "test_withdrawer"
    assert_equal va_histories.last.authorized_withdrawer_after, "test_withdrawer_2"
  end

  test "on authorized withdrawer update CheckGroupValidatorAssignmentWorker should be enqueued" do
    validator = create(:validator)
    vote_account = create(
      :vote_account,
      authorized_withdrawer: "test_withdrawer",
      authorized_voters: { "test_voter_key" => "test_voter_value" },
      validator_identity: "test_validator_identity"
    )
    # remove all enqueued jobs
    Sidekiq::Worker.clear_all

    vote_account.update(authorized_withdrawer: "test_withdrawer_updated")
    assert_equal 1, CheckGroupValidatorAssignmentWorker.jobs.size
  end

  test "on authorized voters key update CheckGroupValidatorAssignmentWorker should not be enqueued" do
    validator = create(:validator)
    vote_account = create(
      :vote_account,
      authorized_withdrawer: "test_withdrawer",
      authorized_voters: { "test_voter_key" => "test_voter_value" },
      validator_identity: "test_validator_identity"
    )
    # remove all enqueued jobs
    Sidekiq::Worker.clear_all

    vote_account.update(authorized_voters: { "test_voter_key_updated" => "test_voter_value" })
    assert_equal 0, CheckGroupValidatorAssignmentWorker.jobs.size
  end

  test "on authorized voters value update CheckGroupValidatorAssignmentWorker should be enqueued" do
    validator = create(:validator)
    vote_account = create(
      :vote_account,
      authorized_withdrawer: "test_withdrawer",
      authorized_voters: { "test_voter_key" => "test_voter_value" },
      validator_identity: "test_validator_identity"
    )
    # remove all enqueued jobs
    Sidekiq::Worker.clear_all

    vote_account.update(authorized_voters: { "test_voter_key" => "test_voter_value_updated" })
    assert_equal 1, CheckGroupValidatorAssignmentWorker.jobs.size
  end

  test "on validator identity update CheckGroupValidatorAssignmentWorker should be enqueued" do
    validator = create(:validator)
    vote_account = create(
      :vote_account,
      authorized_withdrawer: "test_withdrawer",
      authorized_voters: { "test_voter_key" => "test_voter_value" },
      validator_identity: "test_validator_identity"
    )
    # remove all enqueued jobs
    Sidekiq::Worker.clear_all

    vote_account.update(validator_identity: "test_validator_identity_updated")
    assert_equal 1, CheckGroupValidatorAssignmentWorker.jobs.size
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
