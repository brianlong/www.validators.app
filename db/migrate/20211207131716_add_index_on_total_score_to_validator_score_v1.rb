class AddIndexOnTotalScoreToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_score_v1s, :total_score
  end
end
