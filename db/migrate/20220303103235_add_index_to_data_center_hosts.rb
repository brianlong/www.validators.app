class AddIndexToDataCenterHosts < ActiveRecord::Migration[6.1]
  def change
    remove_index :data_center_hosts, :data_center_id
    add_index :data_center_hosts, [:data_center_id, :host], unique: true
  end
end
