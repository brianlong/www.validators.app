require 'test_helper'

class ValidatorBlockHistoryStatTest < ActiveSupport::TestCase
  test 'last_24_hours scopes results to only ones created within the last 24 hours' do
    Timecop.freeze do
      ValidatorBlockHistoryStat.delete_all
      create(:validator_block_history_stat, created_at: 25.hours.ago)
      vbhs1 = create(:validator_block_history_stat, created_at: 24.hours.ago)
      vbhs2 = create(:validator_block_history_stat, created_at: 1.minute.ago)
      vbhs3 = create(:validator_block_history_stat)
      assert_equal(3, ValidatorBlockHistoryStat.last_24_hours.count)
      assert_equal([vbhs1, vbhs2, vbhs3], ValidatorBlockHistoryStat.last_24_hours)
    end
  end

  test 'after_create, #skipped_slot_percent_moving_average is calculated as the moving average for the last 24 hours' do
    validator = create(:validator)
    vbhs1 = create(:validator_block_history_stat, skipped_slot_percent: 0)
    vbhs2 = create(:validator_block_history_stat, skipped_slot_percent: 0.25)
    vbhs3 = create(:validator_block_history_stat, skipped_slot_percent: 0.5)
    vbhs4 = create(:validator_block_history_stat, skipped_slot_percent: 0.75)

    assert_equal(0, vbhs1.skipped_slot_percent_moving_average)
    assert_equal(0.125, vbhs2.skipped_slot_percent_moving_average)
    assert_equal(0.25, vbhs3.skipped_slot_percent_moving_average)
    assert_equal(0.375, vbhs4.skipped_slot_percent_moving_average)
  end
end
