class RemoveColumnsFromDataCenters < ActiveRecord::Migration[6.1]
  def change
    remove_column :data_centers, :traits_domain, :string
    remove_column :data_centers, :traits_ip_address, :string
    remove_column :data_centers, :traits_network, :string
  end
end
