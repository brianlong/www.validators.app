class AddIndexOnTotalScoreToValidatorScoreV2 < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_score_v2s, :total_score
  end
end
