# frozen_string_literal: true

require_relative '../../config/environment'
require_relative '../concerns/fix_data_center_module'

include FixDataCenterModule

ASO = 'OVH SAS'

OVH_HOSTS = {
  'lon1-eri1' => {
    country_iso_code: 'EN',
    country_name: 'Great Britain',
    city_name: 'London',
    data_center_key: '16276-EN-London',
    aso: ASO
  },
  'bhs-g' => {
    country_iso_code: 'CA',
    country_name: 'Canada',
    city_name: 'Beauharnois',
    data_center_key: '16276-CA-Beauharnois',
    aso: ASO
  },
  'waw-d' => {
    country_iso_code: 'PL',
    country_name: 'Poland',
    city_name: 'Warsaw',
    data_center_key: '16276-PL-Warsaw',
    aso: ASO
  },
  'rbx-g' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Roubaix',
    data_center_key: '16276-FR-Roubaix',
    aso: ASO
  },
  'fra1-lim1' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Frankfurt',
    data_center_key: '16276-DE-Frankfurt',
    aso: ASO
  },
  'gra-' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Gravelines',
    data_center_key: '16276-FR-Gravelines',
    aso: ASO
  },
  'sbg-g' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Strasbourg',
    data_center_key: '16276-FR-Strasbourg',
    aso: ASO
  },
  'dc1' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Paris',
    data_center_key: '16276-FR-Paris',
    aso: ASO
  },
  'gsw' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Paris',
    data_center_key: '16276-FR-Paris',
    aso: ASO
  },
  'p19' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Paris',
    data_center_key: '16276-FR-Paris',
    aso: ASO
  },
  'vin' => {
    country_iso_code: 'US',
    country_name: 'United States',
    city_name: 'Vint Hill',
    data_center_key: '16276-US-Vint-Hill',
    aso: ASO
  },
  'hil' => {
    country_iso_code: 'US',
    country_name: 'United States',
    city_name: 'Hillsboro',
    data_center_key: '16276-US-Hillsboro',
    aso: ASO
  }
}

HOST_REGEX = /(be|bg|vl|fra1-lim1).+\.(lon1|rbx|bhs|waw|fra|gra|sbg|hil|vin|p19|gsw|dc1|de).+/

ValidatorIp.joins(:data_center)
           .where("is_active = ? AND is_overridden = ? AND data_centers.traits_autonomous_system_number = ?", true, false, 16_276)
           .each do |vip|

  last_ovh_ip = get_matching_traceroute(ip: vip.address, reg: HOST_REGEX)

  OVH_HOSTS.each do |host_reg, host_data|
    next unless last_ovh_ip&.include?(host_reg)

    host = ('H' + last_ovh_ip).strip.split(' ')[1].strip

    begin
      setup_data_center(vip: vip, host_data: host_data, host: host)
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "#{e.class} - #{e.message}"
      Appsignal.send_error(e)
    end
  end
end

puts 'end of script'
