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
end
