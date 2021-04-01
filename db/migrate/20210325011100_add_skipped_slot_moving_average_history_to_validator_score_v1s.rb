class AddSkippedSlotMovingAverageHistoryToValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :skipped_slot_moving_average_history, :text
  end
end
