# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require File.expand_path('./concerns/fix_ip_module', __dir__)

include FixIpModule

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

HOST_REGEX = /(be|bg|vl).+\.(lon1|rbx|bhs|waw|fra|gra|sbg|hil|vin|p19|gsw|dc1).+/

Ip.where(traits_autonomous_system_number: 16_276)
  .where.not(address: IpOverride.select(:address))
  .each do |ip|
  last_ovh_ip = get_matching_traceroute(ip: ip.address, reg: HOST_REGEX)

  OVH_HOSTS.each do |host_reg, host_data|
    next unless last_ovh_ip&.include?(host_reg)

    host = ('H' + last_ovh_ip).strip.split(' ')[1].strip
    setup_ip_override(ip: ip, host_data: host_data, host: host)
  end
end

# These two methods should run after everything else is done.
update_ip_with_overrides
update_validator_score_with_overrides
