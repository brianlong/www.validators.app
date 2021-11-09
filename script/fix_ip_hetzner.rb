# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/fix_ip_hetzner.rb >> /tmp/fix_ip_hetzner.log 2>&1 &

require_relative '../config/environment'
require_relative './concerns/fix_ip_module'

include FixIpModule

ASO = 'Hetzner Online GmbH'
HETZNER_HOSTS = {
  'fsn1.hetzner.com' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Falkenstein',
    data_center_key: '24940-DE-Falkenstein',
    aso: ASO
  },
  'nbg1.hetzner.com' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Nuremburg',
    data_center_key: '24940-DE-Nuremburg',
    aso: ASO
  },
  'hel.hetzner.com' => {
    country_iso_code: 'FI',
    country_name: 'Finland',
    city_name: 'Helsinki',
    data_center_key: '24940-FI-Helsinki',
    aso: ASO
  },
  'hel1.hetzner.com' => {
    country_iso_code: 'FI',
    country_name: 'Finland',
    city_name: 'Helsinki',
    data_center_key: '24940-FI-Helsinki',
    aso: ASO
  }
}

# Sample data_center_hosts:
#   ex9k1.dc1.nbg1.hetzner.com
#   ex9k1.dc15.fsn1.hetzner.com
#   ex9k1.dc2.hel1.hetzner.com
#   ex9k1.dc4.hel1.hetzner.com
#   ex9k2.dc1.fsn1.hetzner.com
#   ex9k2.dc2.hel1.hetzner.com
#   spine1.cloud1.nbg1.hetzner.com
#   spine2.cloud1.hel1.hetzner.com

HETZNER_REGEX = /(ex|sp).+\.(dc|cloud).+\.hetzner\.com/

Ip.where(traits_autonomous_system_number: 24_940)
  .where('address not in (select address from ip_overrides)')
  .each do |ip|

  last_hetzner_ip = get_matching_traceroute(ip: ip.address, reg: HETZNER_REGEX)

  HETZNER_HOSTS.each do |host_reg, host_data|
    next unless last_hetzner_ip&.include?(host_reg)

    host = ('H' + last_hetzner_ip).strip.split(' ')[1].strip
    setup_ip_override(ip: ip, host_data: host_data, host: host)
    
    Rails.logger.warn "added IP Override: #{ip} - #{host}"

    break
  end
end

update_ip_with_overrides
update_validator_score_with_overrides
puts 'End of Script'

# SQL to use when manually creating IP ip_overrides
#
# Helsinki
# insert into ip_overrides (address, traits_autonomous_system_number, country_iso_code, country_name, city_name, data_center_key, data_center_host, created_at, updated_at) VALUES ('135.181.141.90', 24940, 'FI', 'Finland', 'Helsinki', '24940-FI-Helsinki', 'ex9k1.dc3.hel1.hetzner.com', NOW(), NOW());
#
# Falkenstein
# insert into ip_overrides (address, traits_autonomous_system_number, country_iso_code, country_name, city_name, data_center_key, data_center_host, created_at, updated_at) VALUES ('157.90.34.179', 24940, 'DE', 'Germany', 'Falkenstein', '24940-DE-Falkenstein', 'core23.fsn1.hetzner.com', NOW(), NOW());
#
# UPDATE ips ip INNER JOIN ip_overrides ipor ON ip.address = ipor.address SET ip.traits_autonomous_system_number = ipor.traits_autonomous_system_number, ip.country_iso_code = ipor.country_iso_code, ip.country_name = ipor.country_name, ip.city_name = ipor.city_name, ip.data_center_key = ipor.data_center_key, ip.data_center_host = ipor.data_center_host, ip.traits_autonomous_system_organization = ipor.traits_autonomous_system_organization, ip.updated_at = NOW();
#
# UPDATE validator_score_v2s sc INNER JOIN ips ip ON sc.ip_address = ip.address SET sc.data_center_key = ip.data_center_key, sc.data_center_host = ip.data_center_host, sc.updated_at = NOW();
