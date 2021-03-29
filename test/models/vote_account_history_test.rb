# frozen_string_literal: true

require 'test_helper'

class VoteAccountHistoryTest < ActiveSupport::TestCase
  test 'skipped_vote_percent' do
    assert_equal 0.35, vote_account_histories(:four).skipped_vote_percent
  end

  test 'previous_24_hours' do
    assert_equal (vote_account_histories.count - 1), vote_account_histories(:four).previous_24_hours.count
  end

  test "skipped_vote_percent_moving_average should not be empty after create" do
    vah = VoteAccountHistory.create(
      vote_account_id: 1,
      network: "testnet",
      credits_current: 193916,
      slot_index_current: 299198
    )
    assert_not_nil vah.skipped_vote_percent_moving_average
  end

  test "average of skipped vote percent moving average calculated correctly" do
    average1 = VoteAccountHistory.average_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1234")
    average2 = VoteAccountHistory.average_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1-2-3")

    assert_equal 0.35, average1
    assert_equal 0.2, average2
  end

  test "median of skipped vote percent moving average calculated correctly" do
    median1 = VoteAccountHistory.median_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1234")
    median2 = VoteAccountHistory.median_skipped_vote_percent_moving_average_for(network: 'testnet', batch_uuid: "1-2-3")

    assert_equal 0.4, median1
    assert_equal 0.2, median2
  end
end
