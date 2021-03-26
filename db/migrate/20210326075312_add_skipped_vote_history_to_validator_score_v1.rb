class AddSkippedVoteHistoryToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :skipped_vote_history, :string
  end
end
