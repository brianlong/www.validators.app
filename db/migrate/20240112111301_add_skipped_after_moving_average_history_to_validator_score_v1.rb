class AddSkippedAfterMovingAverageHistoryToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :skipped_after_moving_average_history, :text
  end
end
