class AddIpToScores < ActiveRecord::Migration[6.1]
  def change
    add_column :validator_score_v1s, :ip_address, :string
    add_column :validator_score_v1s, :network, :string
    add_column :validator_score_v1s, :data_center_key, :string
    add_index :validator_score_v1s, %i[network data_center_key]
  end
end
