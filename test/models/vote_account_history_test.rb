# frozen_string_literal: true

require 'test_helper'

class VoteAccountHistoryTest < ActiveSupport::TestCase
  setup do
    v = create(:validator)
    @va = create(:vote_account, validator: v)
  end

  test 'skipped_vote_percent' do
    create(:vote_account_history, vote_account: @va, network: 'mainnet')
    assert_equal 0.9797462716996771, VoteAccountHistory.last.skipped_vote_percent
  end

  test 'skipped_vote_percent for testnet compares credits with max credits' do
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'testnet',
                 max_credits_current: 6_400,
                 credits_current: 5_000)
    assert_in_delta 0.21875, vah.skipped_vote_percent, 0.000001
  end

  test 'skipped_vote_percent for testnet stays in range with alpenglow sized credits' do
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'testnet',
                 max_credits_current: 19_154_183_712_310,
                 credits_current: 18_787_464_805_954)
    assert_in_delta 0.019145, vah.skipped_vote_percent, 0.000001
    assert_operator vah.reload.skipped_vote_percent_moving_average, :>=, 0.0
    assert_operator vah.skipped_vote_percent_moving_average, :<=, 1.0
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

  test 'skipped_vote_percent for alpenglow-community compares credits with max credits' do
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'alpenglow-community',
                 max_credits_current: 6_400,
                 credits_current: 5_000)
    assert_in_delta 0.21875, vah.skipped_vote_percent, 0.000001
  end

  test 'skipped_vote_percent for alpenglow-community clamps to 0 when credits exceed max' do
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'alpenglow-community',
                 max_credits_current: 320,
                 credits_current: 500)
    assert_equal 0.0, vah.skipped_vote_percent
  end

  test 'skipped_vote_percent for alpenglow-community returns nil without max credits' do
    vah = create(:vote_account_history, vote_account: @va,
                 network: 'alpenglow-community',
                 max_credits_current: nil,
                 credits_current: 100)
    assert_nil vah.skipped_vote_percent
  end

  test 'skipped_vote_percent_moving_average does not crash when skipped_vote_percent is nil' do
    assert_nothing_raised do
      create(:vote_account_history, vote_account: @va,
             network: 'alpenglow-community',
             max_credits_current: 0,
             credits_current: 100)
    end
  end
end
