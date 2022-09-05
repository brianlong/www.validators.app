class AddIndexToValidatorScoreV1 < ActiveRecord::Migration[6.1]
  def change
    add_index :validator_score_v1s, [:network, :total_score]
    add_index :validator_score_v1s, [:network, :active_stake]
    add_index :validator_score_v1s, [:network, :validator_id]
  end
end
