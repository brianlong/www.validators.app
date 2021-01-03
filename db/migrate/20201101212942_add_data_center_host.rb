class AddDataCenterHost < ActiveRecord::Migration[6.0]
  def change
    add_column :ips, 'data_center_host', :string
  end
end
