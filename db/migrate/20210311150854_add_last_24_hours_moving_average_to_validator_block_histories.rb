class AddLast24HoursMovingAverageToValidatorBlockHistories < ActiveRecord::Migration[6.0]
  def change
    add_column :validator_block_histories, :last_24_hours_skipped_slot_percent_moving_average, :decimal
  end
end
