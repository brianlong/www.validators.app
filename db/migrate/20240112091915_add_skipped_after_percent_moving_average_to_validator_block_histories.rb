class AddSkippedAfterPercentMovingAverageToValidatorBlockHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_block_histories, :skipped_slot_after_percent_moving_average, :decimal, precision: 10, scale: 4
  end
end
