class CreateDataCenters < ActiveRecord::Migration[6.1]
  def change
    create_table :data_centers do |t|
      t.string :continent_code
      t.integer :continent_geoname_id
      t.string :continent_name
      t.integer :country_confidence
      t.string :country_iso_code
      t.integer :country_geoname_id
      t.string :country_name
      t.string :registered_country_iso_code
      t.integer :registered_country_geoname_id
      t.string :registered_country_name
      t.boolean :traits_anonymous
      t.boolean :traits_hosting_provider
      t.string :traits_user_type
      t.integer :traits_autonomous_system_number
      t.string :traits_autonomous_system_organization
      t.string :traits_domain
      t.string :traits_isp
      t.string :traits_organization
      t.string :traits_ip_address
      t.string :traits_network
      t.integer :city_confidence
      t.integer :city_geoname_id
      t.string :city_name
      t.integer :location_average_income
      t.integer :location_population_density
      t.integer :location_accuracy_radius
      t.decimal :location_latitude, precision: 9, scale: 6
      t.decimal :location_longitude, precision: 9, scale: 6
      t.integer :location_metro_code
      t.string :location_time_zone
      t.integer :postal_confidence
      t.string :postal_code
      t.integer :subdivision_confidence
      t.string :subdivision_iso_code
      t.integer :subdivision_geoname_id
      t.integer :subdivision_name
      t.string :data_center_key
      t.string :data_center_host
      t.timestamps
    end
    add_index :data_centers, :data_center_key
  end
end
