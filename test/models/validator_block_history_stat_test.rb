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
end
