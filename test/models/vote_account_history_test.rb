# frozen_string_literal: true

require 'test_helper'

class VoteAccountHistoryTest < ActiveSupport::TestCase
  test 'skipped_vote_percent' do
    create(:vote_account_history)
    assert_equal 0.35, VoteAccountHistory.last.skipped_vote_percent
  end

  test 'previous_24_hours' do
    create(:vote_account_history, created_at: 2.days.ago)
    create(:vote_account_history)
    create(:vote_account_history)

    assert_equal 2, VoteAccountHistory.last.previous_24_hours.count
  end

  test "skipped_vote_percent_moving_average should not be empty after create" do
    vah = create(:vote_account_history)
    assert_not_nil vah.skipped_vote_percent_moving_average
  end

  test "average of skipped vote percent moving average calculated correctly" do
    create(:vote_account_history, batch_uuid: "1-2-3").update(skipped_vote_percent_moving_average: 0.1)
    create(:vote_account_history, batch_uuid: "1-2-3").update(skipped_vote_percent_moving_average: 0.2)
    create(:vote_account_history, batch_uuid: "1-2-3").update(skipped_vote_percent_moving_average: 0.3)
    create(:vote_account_history, batch_uuid: "1234").update(skipped_vote_percent_moving_average: 0.3)
    create(:vote_account_history, batch_uuid: "1234").update(skipped_vote_percent_moving_average: 0.4)
    average1 = VoteAccountHistory.average_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1234")
    average2 = VoteAccountHistory.average_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1-2-3")

    assert_equal 0.35, average1
    assert_equal 0.2, average2
  end

  test "median of skipped vote percent moving average calculated correctly" do
    create(:vote_account_history, batch_uuid: "1-2-3").update(skipped_vote_percent_moving_average: 0.1)
    create(:vote_account_history, batch_uuid: "1-2-3").update(skipped_vote_percent_moving_average: 0.2)
    create(:vote_account_history, batch_uuid: "1-2-3").update(skipped_vote_percent_moving_average: 0.3)
    create(:vote_account_history, batch_uuid: "1234").update(skipped_vote_percent_moving_average: 0.3)
    create(:vote_account_history, batch_uuid: "1234").update(skipped_vote_percent_moving_average: 0.4)
    median1 = VoteAccountHistory.median_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1234")
    median2 = VoteAccountHistory.median_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1-2-3")

    assert_equal 0.4, median1
    assert_equal 0.2, median2
  end
end
