class CreateIpOverrides < ActiveRecord::Migration[6.1]
  def change
    create_table :ip_overrides do |t|
      t.string 'address'
      t.integer 'traits_autonomous_system_number'
      t.string 'country_iso_code'
      t.string 'country_name'
      t.string 'city_name'
      t.string 'data_center_key'
      t.string 'data_center_host'
      t.timestamps
    end
    add_index :ip_overrides, :address, unique: true
  end
end
