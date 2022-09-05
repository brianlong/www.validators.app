class UpdateIndexInDataCenters < ActiveRecord::Migration[6.1]
  def change
    remove_index :data_centers, :data_center_key, name: "index_data_centers_on_data_center_key", if_exists: true

    add_index :data_centers, [:data_center_key, :traits_autonomous_system_number, :traits_autonomous_system_organization, :country_iso_code], name: "index_data_centers_for_grouping"
  end
end
