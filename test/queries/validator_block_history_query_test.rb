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
  end

  def teardown
    super

    @validator_block_histories.each(&:destroy)
  end

  def test_for_batch
    expected = @validator_block_histories[0...-1]

    assert_equal expected, @query.for_batch.to_a
  end
end
