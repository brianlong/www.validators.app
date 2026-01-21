class AddIbrlScoreToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :ibrl_score, :float
  end
end
