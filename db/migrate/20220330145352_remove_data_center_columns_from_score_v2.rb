class RemoveDataCenterColumnsFromScoreV2 < ActiveRecord::Migration[6.1]
  def change
    remove_column :validator_score_v2s, :data_center_key, :string
    remove_column :validator_score_v2s, :data_center_host, :string
    remove_index :validator_score_v2s, name: "index_validator_score_v2s_on_network_and_data_center_key"
  end
end
