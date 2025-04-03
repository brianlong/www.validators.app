class AddVoteLatencyToValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :vote_latency_history, :text
    add_column :validator_score_v1s, :vote_latency_score, :integer
  end
end
