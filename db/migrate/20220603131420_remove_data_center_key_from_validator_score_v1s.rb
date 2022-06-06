class RemoveDataCenterKeyFromValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    remove_column :validator_score_v1s, :data_center_key, :string
  end
end
