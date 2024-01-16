require 'test_helper'

class ValidatorBlockHistoryTest < ActiveSupport::TestCase
  setup { @validator = create(:validator) }

  test '#previous_24_hours returns other ValidatorBlockHistory records for the same validator created within 24 hours of the subject (`self`)' do
    create(:validator_block_history, created_at: 25.hours.ago, validator: @validator)
    vbh1 = create(:validator_block_history, created_at: 23.hours.ago, validator: @validator)
    vbh2 = create(:validator_block_history, created_at: 1.minute.ago, validator: @validator)
    vbh3 = create(:validator_block_history, validator: @validator)
    assert_equal(3, vbh3.previous_24_hours.count)
    assert_equal([vbh1, vbh2, vbh3], vbh3.previous_24_hours)
  end

  test 'after_create, #skipped_slot_percent_moving_average is calculated as the moving average for the last 24 hours' do
    vbh1 = create(:validator_block_history, validator: @validator, skipped_slot_percent: 0)
    vbh2 = create(:validator_block_history, validator: @validator, skipped_slot_percent: 0.25)
    vbh3 = create(:validator_block_history, validator: @validator, skipped_slot_percent: 0.5)
    vbh4 = create(:validator_block_history, validator: @validator, skipped_slot_percent: 0.75)

    assert_equal(0, vbh1.skipped_slot_percent_moving_average)
    assert_equal(0.125, vbh2.skipped_slot_percent_moving_average)
    assert_equal(0.25, vbh3.skipped_slot_percent_moving_average)
    assert_equal(0.375, vbh4.skipped_slot_percent_moving_average)
  end

  test 'after_create, #skipped_slot_after_percent_moving_average is calculated as the moving average for the last 24 hours' do
    vbh1 = create(:validator_block_history, validator: @validator, skipped_slots_after_percent: 0)
    vbh2 = create(:validator_block_history, validator: @validator, skipped_slots_after_percent: 0.25)
    vbh3 = create(:validator_block_history, validator: @validator, skipped_slots_after_percent: 0.5)
    vbh4 = create(:validator_block_history, validator: @validator, skipped_slots_after_percent: 0.75)

    assert_equal(0, vbh1.skipped_slot_after_percent_moving_average)
    assert_equal(0.125, vbh2.skipped_slot_after_percent_moving_average)
    assert_equal(0.25, vbh3.skipped_slot_after_percent_moving_average)
    assert_equal(0.375, vbh4.skipped_slot_after_percent_moving_average)
  end

  test 'has_one batch relationship works correctly' do
    batch = create(:batch)
    vbhs = create_list(:validator_block_history, 3, batch_uuid: batch.uuid)

    vbhs.each do |vbh|
      assert_equal batch, vbh.batch
    end
  end

  test ':for_batch' do
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
    expected = @validator_block_histories[0...-1]

    assert_equal expected, ValidatorBlockHistory.for_batch(network, batch_uuid).to_a

    @validator_block_histories.each(&:destroy)
  end
end
