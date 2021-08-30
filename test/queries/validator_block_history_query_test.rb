# frozen_string_literal: true

require 'test_helper'

class ValidatorBlockHistoryQueryTest < ActiveSupport::TestCase
  def setup
    super

    network = 'testnet'
    batch_uuid = create(:batch).uuid

    @validator_block_histories = [
      create(:validator_block_history, network: network, batch_uuid: batch_uuid,
                                       skipped_slot_percent: 0.12),
      create(:validator_block_history, network: network, batch_uuid: batch_uuid,
                                       skipped_slot_percent: 0.19),
      create(:validator_block_history, network: network, batch_uuid: batch_uuid,
                                       skipped_slot_percent: 0.11),
      create(:validator_block_history, network: network, batch_uuid: batch_uuid,
                                       skipped_slot_percent: 0.83),
      create(:validator_block_history, skipped_slot_percent: 0.45)
    ]

    @query = ValidatorBlockHistoryQuery.new(network, batch_uuid)
    @skipped_slot_percent =
      @validator_block_histories[0...-1].map(&:skipped_slot_percent)
  end

  def teardown
    super

    @validator_block_histories.each(&:destroy)
  end

  test 'average_skipped_slot_percent' do
    expected = @skipped_slot_percent.sum / @skipped_slot_percent.size.to_f
    assert_equal expected, @query.average_skipped_slot_percent
  end

  test 'median_skipped_slot_percent' do
    expected = @skipped_slot_percent.sort[@skipped_slot_percent.size / 2]
    assert_equal expected, @query.median_skipped_slot_percent
  end

  test 'skipped_slot_percent_history_moving_average' do
    expected = [0.12e0, 0.19e0, 0.11e0, 0.83e0]
    assert_equal expected, @query.skipped_slot_percent_history_moving_average.map(&:first)
  end

  test 'skipped_slot_percent_history' do
    expected = [0.12e0, 0.19e0, 0.11e0, 0.83e0]
    assert_equal expected, @query.skipped_slot_percent_history
  end

  test 'top_skipped_slot_percent' do
    expected = [0.11, 0.12, 0.19, 0.83]
    assert_equal expected, @query.top_skipped_slot_percent.map(&:first)
  end

  test 'skipped_slot_stats' do
    expected = {
      min: 0.11e0, max: 0.83e0, median: 0.19e0, average: 0.3125e0
    }
    assert_equal expected, @query.skipped_slot_stats
  end

  test 'skipped_slot_stats with history' do
    expected = {
      min: 0.11e0, max: 0.83e0, median: 0.19e0, average: 0.3125e0
    }
    expected_history = [0.12e0, 0.19e0, 0.11e0, 0.83e0]

    assert_equal expected, @query.skipped_slot_stats(with_history: false)
    assert_equal expected_history, @query.skipped_slot_stats(with_history: true)[:history].map(&:first)
  end

end
