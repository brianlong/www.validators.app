class RemoveDataCenterKeyFromValidatorScoreV1s < ActiveRecord::Migration[6.1]
  def change
    remove_column :validator_score_v1s, :data_center_key, :string
    rename_index :validator_score_v1s, 'index_validator_score_v1s_on_network_and_data_center_key', 'index_validator_score_v1s_on_network'
  end
end
