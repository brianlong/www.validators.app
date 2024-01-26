# frozen_string_literal: true

require "test_helper"

class RemoveValidatorTest < ActiveSupport::TestCase

  def load_script(validator)
    @network = 'testnet'
    @account = validator.account
    path = Rails.root.join("script", "one_time_scripts", "remove_validator.rb").to_s

    eval(File.read(path))
  end

  test "script removes validator with its all relations" do
    validator_history = build(:validator_history)
    validator_block_history = build(:validator_block_history)
    account_authority_history = build(:account_authority_history)
    vote_account_history = build(:vote_account_history)
    vote_account = build(
      :vote_account,
      account_authority_histories: [account_authority_history],
      vote_account_histories: [vote_account_history]
    )
    commission_history = build(:commission_history)
    stake_account_history = build(:stake_account_history)
    stake_account = build(:stake_account)
    validator_ip = build(:validator_ip)
    validator_score_v1 = build(:validator_score_v1)
    user_watchlist_element = build(:user_watchlist_element)

    validator = create(
      :validator,
      validator_histories: [validator_history],
      validator_block_histories: [validator_block_history],
      vote_accounts: [vote_account],
      commission_histories: [commission_history],
      stake_account_histories: [stake_account_history],
      stake_accounts: [stake_account],
      validator_ips: [validator_ip],
      validator_score_v1: validator_score_v1,
      user_watchlist_elements: [user_watchlist_element]
    )

    assert validator_history.persisted?
    assert validator_block_history.persisted?
    assert account_authority_history.persisted?
    assert vote_account_history.persisted?
    assert vote_account.persisted?
    assert commission_history.persisted?
    assert stake_account_history.persisted?
    assert stake_account.persisted?
    assert validator_ip.persisted?
    assert validator_score_v1.persisted?
    assert user_watchlist_element.persisted?

    load_script(validator)

    assert_raises(ActiveRecord::RecordNotFound) do
      validator_history.reload
      validator_block_history.reload
      account_authority_history.reload
      vote_account_history.reload
      vote_account.reload
      commission_history.reload
      stake_account_history.reload
      stake_account.reload
      validator_ip.reload
      validator_score_v1.reload
      user_watchlist_element.reload
      validator.reload
    end
  end
end
