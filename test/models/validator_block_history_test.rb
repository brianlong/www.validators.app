require 'test_helper'

class ValidatorBlockHistoryTest < ActiveSupport::TestCase
  test 'last_24_hours scopes results to only ones created within the last 24 hours' do
    Timecop.freeze do
      ValidatorBlockHistory.delete_all
      create(:validator_block_history, created_at: 25.hours.ago)
      vbh1 = create(:validator_block_history, created_at: 24.hours.ago)
      vbh2 = create(:validator_block_history, created_at: 1.minute.ago)
      vbh3 = create(:validator_block_history)
      assert_equal(3, ValidatorBlockHistory.last_24_hours.count)
      assert_equal([vbh1, vbh2, vbh3], ValidatorBlockHistory.last_24_hours)
    end
  end

  test 'after_create, #skipped_slot_percent_moving_average is calculated as the moving average for the last 24 hours' do
    validator = create(:validator)
    vbh1 = create(:validator_block_history, validator: validator, skipped_slot_percent: 0)
    vbh2 = create(:validator_block_history, validator: validator, skipped_slot_percent: 0.25)
    vbh3 = create(:validator_block_history, validator: validator, skipped_slot_percent: 0.5)
    vbh4 = create(:validator_block_history, validator: validator, skipped_slot_percent: 0.75)

    assert_equal(0, vbh1.skipped_slot_percent_moving_average)
    assert_equal(0.125, vbh2.skipped_slot_percent_moving_average)
    assert_equal(0.25, vbh3.skipped_slot_percent_moving_average)
    assert_equal(0.375, vbh4.skipped_slot_percent_moving_average)
  end
end
