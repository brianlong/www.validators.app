class AddIndexOnNetworkAndDataCentersIdToDcStats < ActiveRecord::Migration[6.1]
  def change
    add_index :data_center_stats, [:network, :data_center_id], unique: true
  end
end
