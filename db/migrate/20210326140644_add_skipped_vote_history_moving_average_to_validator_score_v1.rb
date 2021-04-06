class AddSkippedVoteHistoryMovingAverageToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :skipped_vote_percent_moving_average_history, :text
  end
end
