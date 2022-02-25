# frozen_string_literal: true

require File.expand_path("../config/environment", __dir__)
require File.expand_path("./concerns/fix_ip_module", __dir__)

include FixIpModule

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
  }
}

HOST_REGEX = /(tier-four|ip4)\.(demarc|gtt).+/

ValidatorIp.joins(:data_center)
           .where("is_overridden = ? AND data_centers.traits_autonomous_system_number = ?", false, 18_450)
           .each do |vip|

  last_webnx_ip = get_matching_traceroute(ip: vip.address, reg: HOST_REGEX)

  WEBNX_HOSTS.each do |host_reg, host_data|
    next unless last_webnx_ip&.include?(host_reg)

    host = ("H" + last_webnx_ip).strip.split(" ")[1].strip
    setup_ip_override(vip: vip, host_data: host_data, host: host)
  end
end
          
# These two methods should run after everything else is done.
# update_ip_with_overrides
update_validator_score_with_overrides

puts "end of script"
