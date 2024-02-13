# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/fix_data_centers_hetzner.rb >> /tmp/fix_data_center_hetzner.log 2>&1 &

require_relative '../../config/environment'
require_relative '../concerns/fix_data_center_module'

include FixDataCenterModule

ASO = 'RELIABLESITE'
ASN = 23470
REGISTERED_COUNTRY_NAME = "United States" 
RELIABLESITE_HOSTS_COMMON = {
  country_iso_code: "US",
  country_name: "United States",
  registered_country_name: REGISTERED_COUNTRY_NAME,
  aso: ASO
}

RELIABLESITE_HOSTS = {
  "losangeles" => {
    city_name: "Los Angeles",
    data_center_key: "23470-US-Los Angeles",
  }.merge(RELIABLESITE_HOSTS_COMMON),
  "miami|nota" => {
    city_name: 'Miami',
    data_center_key: '23470-US-Miami',
  }.merge(RELIABLESITE_HOSTS_COMMON),
  "newark|newyork|UnAssigned24.nyiix.net" => {
    city_name: 'New York',
    data_center_key: "23470-US-New York",
  }.merge(RELIABLESITE_HOSTS_COMMON),
}

RELIABLESITE_REGEXP = /miami|nota|newark|newyork|losangeles|UnAssigned24.nyiix.net/

ValidatorIp.joins(:data_center)
           .where(
              "is_active = ? AND is_overridden = ? AND data_centers.traits_autonomous_system_number = ?", 
              true, false, ASN
            ).each do |vip|

  last_reliablesite_ip = get_matching_traceroute(ip: vip.address, reg: RELIABLESITE_REGEXP, hops_number: 30)

  RELIABLESITE_HOSTS.each do |host_region, host_data|
    regexp = /#{host_region}/

    next unless last_reliablesite_ip&.match?(regexp)

    host = last_reliablesite_ip.strip.split(' ').select { |ip| ip.match?(regexp) }.last

    # traceroute sometimes reach NY and it got lost in the internal NY network,
    # we can assume it's New York data center, but the host can't be retrieved
    if host == "UnAssigned24.nyiix.net"
      host = nil
    end

    setup_data_center(vip: vip, host_data: host_data, host: host)
  end
end
