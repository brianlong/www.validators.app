require 'test_helper'

class ValidatorBlockHistoryStatTest < ActiveSupport::TestCase
  test 'previous_24_hours scopes results to only ones created within the last 24 hours' do
    Timecop.freeze do
      ValidatorBlockHistoryStat.delete_all
      create(:validator_block_history_stat, created_at: 25.hours.ago, network: 'mainnet')
      vbhs1 = create(:validator_block_history_stat, created_at: 24.hours.ago, network: 'mainnet')
      vbhs2 = create(:validator_block_history_stat, created_at: 1.minute.ago, network: 'mainnet')
      create(:validator_block_history_stat, created_at: 1.minute.ago, network: 'testnet')
      vbhs3 = create(:validator_block_history_stat, network: 'mainnet')
      assert_equal(3, vbhs3.previous_24_hours.count)
      assert_equal([vbhs1, vbhs2, vbhs3], vbhs3.previous_24_hours)
    end
  end

  test 'after_create, #skipped_slot_percent_moving_average is calculated as the moving average for whole batch' do
    ValidatorBlockHistoryStat.delete_all
    ValidatorBlockHistory.delete_all
    batch = create(:batch)
    create(:validator_block_history, batch_uuid: batch.uuid, skipped_slot_percent: 0.10)
    create(:validator_block_history, batch_uuid: batch.uuid, skipped_slot_percent: 0.20)
    create(:validator_block_history, batch_uuid: batch.uuid, skipped_slot_percent: 0.30)
    vbhs = create(
      :validator_block_history_stat,
      batch_uuid: batch.uuid,
      network: 'testnet'
    )
    assert_equal(0.2, vbhs.skipped_slot_percent_moving_average)

    create(:validator_block_history, batch_uuid: batch.uuid, skipped_slot_percent: 0.40)
    create(:validator_block_history, batch_uuid: batch.uuid, skipped_slot_percent: 0.50)
    create(:validator_block_history, batch_uuid: batch.uuid, skipped_slot_percent: 0.60)
    ValidatorBlockHistoryStat.delete_all
    vbhs = create(
      :validator_block_history_stat,
      batch_uuid: batch.uuid,
      network: 'testnet'
    )
    assert_equal(0.35, vbhs.skipped_slot_percent_moving_average)
  end
end
