require 'test_helper'

class ValidatorBlockHistoryStatTest < ActiveSupport::TestCase
  test 'previous_24_hours scopes results to only ones created within the last 24 hours' do
    Timecop.freeze do
      create(:validator_block_history_stat, created_at: 25.hours.ago, network: 'mainnet')
      vbhs1 = create(:validator_block_history_stat, created_at: 24.hours.ago, network: 'mainnet')
      vbhs2 = create(:validator_block_history_stat, created_at: 1.minute.ago, network: 'mainnet')
      create(:validator_block_history_stat, created_at: 1.minute.ago, network: 'testnet')
      vbhs3 = create(:validator_block_history_stat, network: 'mainnet')
      assert_equal(3, vbhs3.previous_24_hours.count)
      assert_equal([vbhs1, vbhs2, vbhs3], vbhs3.previous_24_hours)
    end
  end

  test 'after_create, #skipped_slot_percent_moving_average is calculated as the moving average for the last 24 hours' do
    vbhs1 = create(
      :validator_block_history_stat,
      total_slots: 100,
      total_slots_skipped: 0,
      created_at: 3.minutes.ago
    )

    vbhs2 = create(
      :validator_block_history_stat,
      total_slots: 100,
      total_slots_skipped: 25,
      created_at: 2.minutes.ago
    )

    vbhs3 = create(
      :validator_block_history_stat,
      total_slots: 100,
      total_slots_skipped: 50,
      created_at: 1.minute.ago
    )

    vbhs4 = create(
      :validator_block_history_stat,
      total_slots: 100,
      total_slots_skipped: 75
    )

    assert_equal(0, vbhs1.skipped_slot_percent_moving_average)
    assert_equal(0.125, vbhs2.skipped_slot_percent_moving_average)
    assert_equal(0.25, vbhs3.skipped_slot_percent_moving_average)
    assert_equal(0.375, vbhs4.skipped_slot_percent_moving_average)
  end
end
