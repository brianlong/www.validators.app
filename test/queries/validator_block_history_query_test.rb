# frozen_string_literal: true

require 'test_helper'

# TODO: docsss
class ValidatorBlockHistoryQueryTest < ActiveSupport::TestCase
  def setup
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

  test 'average_skipped_slot_percent' do
    expected = @skipped_slot_percent.sum / @skipped_slot_percent.size.to_f
    assert_equal expected, @query.average_skipped_slot_percent
  end

  test 'median_skipped_slot_percent' do
    expected = @skipped_slot_percent.sort[@skipped_slot_percent.size / 2]
    assert_equal expected, @query.median_skipped_slot_percent
  end
end
