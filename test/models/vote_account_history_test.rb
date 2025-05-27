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
end
