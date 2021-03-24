# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require File.expand_path('./concerns/fix_ip_module', __dir__)

include FixIpModule

OVH_HOSTS = {
  'lon1-eri1' => {
    country_iso_code: 'EN',
    country_name: 'Great Britain',
    city_name: 'London',
    data_center_key: '16276-EN-London'
  },
  'bhs-g' => {
    country_iso_code: 'CA',
    country_name: 'Canada',
    city_name: 'Beauharnois',
    data_center_key: '16276-CA-Beauharnois'
  },
  'waw-d' => {
    country_iso_code: 'PL',
    country_name: 'Poland',
    city_name: 'Warsaw',
    data_center_key: '16276-PL-Warsaw'
  },
  'rbx-g' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Roubaix',
    data_center_key: '16276-FR-Paris'
  },
  'fra1-lim1' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Frankfurt',
    data_center_key: '16276-FR-Paris'
  },
  'gra-' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Gravelines',
    data_center_key: '16276-FR-Gravelines'
  },
  'sbg-g' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Strasbourg',
    data_center_key: '16276-FR-Strasbourg'
  }
}

Ip.where(traits_autonomous_system_number: 16276)
  .where('address not in (select address from ip_overrides)')
  .each do |ip|
  last_ovh_ip = get_matching_traceroute(ip.address, /(be|bg|vl).+(lon1|rbx|bhs|waw|fra|gra|sbg).+/)

  OVH_HOSTS.each do |host_reg, host_data|
    next unless last_ovh_ip&.include?(host_reg)
    host = last_ovh_ip.strip.split(" ")[1].strip
    setup_ip_override(ip, host_data, host)
  end

  update_ip_with_overrides()
  update_validator_score_with_overrides()
end

