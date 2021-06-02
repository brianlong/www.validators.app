# frozen_string_literal: true

require 'test_helper'

# Query Objects for searching for ValidatorHistory relations and objects
class ValidatorHistoryQueryTest < ActiveSupport::TestCase
  def setup
    super

    network = 'testnet'
    batch_uuid = create(:batch).uuid
    @validator_history_query =
      ValidatorHistoryQuery.new(network, batch_uuid)

    @validator_histories = [
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 2, last_vote: 21, active_stake: 10),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 4, last_vote: 18, active_stake: 90),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 6, last_vote: 15, active_stake: 20),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 8, last_vote: 12, active_stake: 40),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 10, last_vote: 9, active_stake: 70),
      create(:validator_history, batch_uuid: batch_uuid,
                                 root_block: 12, last_vote: 6, active_stake: 50),
      create(:validator_history, root_block: 14, last_vote: 3, active_stake: 30)
    ]

    @root_blocks = @validator_histories[0...-1].map(&:root_block)
    @last_votes = @validator_histories[0...-1].map(&:last_vote)
    @active_stakes = @validator_histories[0...-1].map(&:active_stake)
  end

  def teardown
    super

    @validator_histories.each(&:destroy)
  end

  test 'for_batch' do
    results = @validator_history_query.for_batch

    assert_equal results, @validator_histories.values_at(0, 1, 2, 3, 4, 5)
    assert_not_includes results, @validator_histories.last
  end

  test 'average_root_block' do
    expected = @root_blocks.sum / @root_blocks.size.to_f
    assert_equal expected, @validator_history_query.average_root_block
  end

  test 'highest_root_block' do
    expected = @root_blocks.max
    assert_equal expected, @validator_history_query.highest_root_block
  end

  test 'median_root_block' do
    expected = @root_blocks.sort[@root_blocks.size / 2]
    assert_equal expected, @validator_history_query.median_root_block
  end

  test 'average_last_vote' do
    expected = @last_votes.sum / @last_votes.size.to_f
    assert_equal expected, @validator_history_query.average_last_vote
  end

  test 'highest_last_vote' do
    expected = @last_votes.max
    assert_equal expected, @validator_history_query.highest_last_vote
  end

  test 'median_last_vote' do
    expected = @last_votes.sort[@last_votes.size / 2]
    assert_equal expected, @validator_history_query.median_last_vote
  end

  test 'total_active_stake' do
    expected = @active_stakes.sum
    assert_equal expected, @validator_history_query.total_active_stake
  end

  test 'upto_33_stake' do
    expected = @validator_histories.values_at(1, 4)
    assert_equal expected, @validator_history_query.upto_33_stake
  end

  test 'at_33_stake' do
    expected = @validator_histories[4]
    assert_equal expected, @validator_history_query.at_33_stake
  end
end
