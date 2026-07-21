# frozen_string_literal: true

require 'test_helper'

class VoteAccountHistoryTest < ActiveSupport::TestCase
  setup do
    v = create(:validator)
    @va = create(:vote_account, validator: v)
  end

  test 'skipped_vote_percent' do
    create(:vote_account_history, vote_account: @va)
    assert_equal 0.9594924757058465, VoteAccountHistory.last.skipped_vote_percent
  end

  test 'previous_24_hours' do
    create(:vote_account_history, created_at: 2.days.ago, vote_account: @va)
    create(:vote_account_history, vote_account: @va)
    create(:vote_account_history, vote_account: @va)

    assert_equal 2, VoteAccountHistory.last.previous_24_hours.count
  end

  test "skipped_vote_percent_moving_average should not be empty after create" do
    vah = create(:vote_account_history, vote_account: @va)
    assert_not_nil vah.skipped_vote_percent_moving_average
  end

  test 'skipped_vote_percent for alpenglow-community uses stake-normalized formula' do
    # max_credits = slot_index_current * 32 * (activated_stake / 1_000_000_000)
    # = 100 * 32 * 2.0 = 6400
    # skipped = (6400 - 5000) / 6400 = 0.21875
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'alpenglow-community',
                 slot_index_current: 100,
                 activated_stake: 2_000_000_000,
                 credits_current: 5_000)
    assert_in_delta 0.21875, vah.skipped_vote_percent, 0.000001
  end

  test 'skipped_vote_percent for alpenglow-community clamps to 0 when credits exceed max' do
    # max_credits = 10 * 32 * 1.0 = 320 — credits_current (500) > max → clamp to 0
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'alpenglow-community',
                 slot_index_current: 10,
                 activated_stake: 1_000_000_000,
                 credits_current: 500)
    assert_equal 0.0, vah.skipped_vote_percent
  end

  test 'skipped_vote_percent for alpenglow-community returns nil when stake is zero' do
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'alpenglow-community',
                 slot_index_current: 100,
                 activated_stake: 0,
                 credits_current: 100)
    assert_nil vah.skipped_vote_percent
  end

  test 'skipped_vote_percent_moving_average does not crash when skipped_vote_percent is nil' do
    # activated_stake: 0 causes skipped_vote_percent to return nil for alpenglow
    assert_nothing_raised do
      create(:vote_account_history, vote_account: @va,
             network: 'alpenglow-community',
             slot_index_current: 100,
             activated_stake: 0,
             credits_current: 100)
    end
  end
end
