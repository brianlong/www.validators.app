# frozen_string_literal: true

require_relative '../../config/environment'
require_relative '../concerns/fix_data_center_module'

include FixDataCenterModule

ASO = "WEBNX"

WEBNX_HOSTS = {
  "tier-four.demarc" => {
    country_iso_code: "US",
    country_name: "United States",
    city_name: "Ogden",
    data_center_key: "18450-US-Ogden",
    aso: ASO
  },
  "ip4.gtt.net" => {
    country_iso_code: "US",
    country_name: "United States",
    city_name: "Los Angeles",
    data_center_key: "18450-US-Los Angeles",
    aso: ASO
  },
  "static.nyinternet.net" => {
    country_iso_code: "US",
    country_name: "United States",
    city_name: "New York",
    data_center_key: "18450-US-New York",
    aso: ASO
  }
}

HOST_REGEX = /(tier-four|ip4|static)\.(demarc|gtt|nyinternet).+/

ValidatorIp.joins(:data_center)
           .where("is_active = ? AND is_overridden = ? AND data_centers.traits_autonomous_system_number = ?", true, false, 18_450)
           .each do |vip|

  last_webnx_ip = get_matching_traceroute(ip: vip.address, reg: HOST_REGEX)

  WEBNX_HOSTS.each do |host_reg, host_data|
    next unless last_webnx_ip&.include?(host_reg)

    host = ("H" + last_webnx_ip).strip.split(" ")[1].strip
    setup_data_center(vip: vip, host_data: host_data, host: host)
  end
end

puts "end of script"
