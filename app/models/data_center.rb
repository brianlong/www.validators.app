# frozen_string_literal: true

# == Schema Information
#
# Table name: data_centers
#
#  id                                    :bigint           not null, primary key
#  city_confidence                       :integer
#  city_name                             :string(191)
#  continent_code                        :string(191)
#  continent_name                        :string(191)
#  country_confidence                    :integer
#  country_iso_code                      :string(191)
#  country_name                          :string(191)
#  data_center_key                       :string(191)
#  location_accuracy_radius              :integer
#  location_average_income               :integer
#  location_latitude                     :decimal(9, 6)
#  location_longitude                    :decimal(9, 6)
#  location_metro_code                   :integer
#  location_population_density           :integer
#  location_time_zone                    :string(191)
#  postal_code                           :string(191)
#  postal_confidence                     :integer
#  registered_country_iso_code           :string(191)
#  registered_country_name               :string(191)
#  subdivision_confidence                :integer
#  subdivision_iso_code                  :string(191)
#  subdivision_name                      :integer
#  traits_anonymous                      :boolean
#  traits_autonomous_system_number       :integer
#  traits_autonomous_system_organization :string(191)
#  traits_hosting_provider               :boolean
#  traits_isp                            :string(191)
#  traits_organization                   :string(191)
#  traits_user_type                      :string(191)
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
#  index_data_centers_for_grouping                        (data_center_key,traits_autonomous_system_number,traits_autonomous_system_organization,country_iso_code)
#  index_data_centers_on_traits_autonomous_system_number  (traits_autonomous_system_number)
#
class DataCenter < ApplicationRecord
  # Data Center for validators not assigned anywhere (mostly due to lack of validator_ip) 
  UNKNOWN_DATA_CENTER_KEY = "0--Unknown"

  FIELDS_FOR_API = %i[
    country_name
    data_center_key 
    id
    location_latitude 
    location_longitude
    traits_autonomous_system_number 
  ].freeze

  FIELDS_FOR_GOSSIP_NODES = [
    "country_name",
    "data_center_key" ,
    "location_latitude as latitude" ,
    "location_longitude as longitude"
  ].freeze

  before_save :assign_data_center_key
  has_many :data_center_hosts
  has_many :validator_ips, through: :data_center_hosts
  has_many :validator_ips_active, through: :data_center_hosts
  has_many :validators, through: :data_center_hosts
  has_many :validator_score_v1s, through: :data_center_hosts
  has_many :gossip_nodes, through: :data_center_hosts

  scope :for_api, -> { select(FIELDS_FOR_API) }

  scope :by_data_center_key, ->(data_center_keys) do
    where(data_center_key: data_center_keys)
  end

  def to_builder
    Jbuilder.new do |data_center|
      data_center.data_center_key self.data_center_key
      data_center.autonomous_system_number self.traits_autonomous_system_number
      data_center.latitude self.location_latitude
      data_center.longitude self.location_longitude
    end
  end

  private

  def assign_data_center_key
    self.data_center_key = "#{traits_autonomous_system_number}-#{country_iso_code}-#{city_name || location_time_zone}"
  end
end
