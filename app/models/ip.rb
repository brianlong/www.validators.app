# == Schema Information
#
# Table name: ips
#
#  id                                    :bigint           not null, primary key
#  address                               :string(255)
#  city_confidence                       :integer
#  city_name                             :string(255)
#  continent_code                        :string(255)
#  continent_name                        :string(255)
#  country_confidence                    :integer
#  country_iso_code                      :string(255)
#  country_name                          :string(255)
#  data_center_host                      :string(255)
#  data_center_key                       :string(255)
#  location_accuracy_radius              :integer
#  location_average_income               :integer
#  location_latitude                     :decimal(9, 6)
#  location_longitude                    :decimal(9, 6)
#  location_metro_code                   :integer
#  location_population_density           :integer
#  location_time_zone                    :string(255)
#  postal_code                           :string(255)
#  postal_confidence                     :integer
#  registered_country_iso_code           :string(255)
#  registered_country_name               :string(255)
#  subdivision_confidence                :integer
#  subdivision_iso_code                  :string(255)
#  subdivision_name                      :integer
#  traits_anonymous                      :boolean
#  traits_autonomous_system_number       :integer
#  traits_autonomous_system_organization :string(255)
#  traits_domain                         :string(255)
#  traits_hosting_provider               :boolean
#  traits_ip_address                     :string(255)
#  traits_isp                            :string(255)
#  traits_network                        :string(255)
#  traits_organization                   :string(255)
#  traits_user_type                      :string(255)
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  city_geoname_id                       :integer
#  continent_geoname_id                  :integer
#  country_geoname_id                    :integer
#  registered_country_geoname_id         :integer
#  subdivision_geoname_id                :integer
#
# Indexes
#
#  index_ips_on_address          (address) UNIQUE
#  index_ips_on_data_center_key  (data_center_key)
#
class Ip < ApplicationRecord
  before_save :assign_data_center_key

  private

  def assign_data_center_key
    self.data_center_key = "#{traits_autonomous_system_number}-#{country_iso_code}-#{city_name || location_time_zone}"
  end
end
