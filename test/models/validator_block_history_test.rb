require 'test_helper'

class ValidatorBlockHistoryTest < ActiveSupport::TestCase
  test 'associated_block_histories returns other block histories for the same validator' do
    validator = create(:validator)
    vbh1 = create(:validator_block_history, validator: validator)
    vbh2 = create(:validator_block_history, validator: validator)
    vbh3 = create(:validator_block_history, validator: validator)
    create(:validator_block_history)

    assert_equal([vbh2, vbh3], vbh1.associated_block_histories)
  end

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

  test 'after_create, #last_24_hours_skipped_slot_percent_moving_average is calculated' do

  end
end
