class RemoveDataCenterHostFromDataCenters < ActiveRecord::Migration[6.1]
  def change
    remove_column :data_centers, :data_center_host, :string
  end
end
