# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/fix_data_centers_hetzner.rb >> /tmp/fix_data_center_hetzner.log 2>&1 &

require_relative '../../config/environment'
require_relative '../concerns/fix_data_center_module'

include FixDataCenterModule

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

ValidatorIp.joins(:data_center)
           .where("is_active = ? AND is_overridden = ? AND data_centers.traits_autonomous_system_number = ?", true, false, 24_940)
           .each do |vip|

  last_hetzner_ip = get_matching_traceroute(ip: vip.address, reg: HETZNER_REGEX)

  HETZNER_HOSTS.each do |host_reg, host_data|
    next unless last_hetzner_ip&.include?(host_reg)

    host = ("H" + last_hetzner_ip).strip.split(" ")[1].strip

    begin
      setup_data_center(vip: vip, host_data: host_data, host: host)

      Rails.logger.warn "added IP Override: #{vip} - #{host}"

      break
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "#{e.class}: #{e.message}"
      Appsignal.send_error(e)

      break
    end
  end
end

puts 'End of Script'
