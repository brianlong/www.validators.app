module FixIpModule

  def get_matching_traceroute(ip, reg)
    traceroute =  `traceroute -m 20 #{ip}`.split("\n")
    last_ovh_ip = nil
    traceroute.each do |line|
      next unless line.match?(reg)
      # furhtest ovh ip from traceroute
      last_ovh_ip = line
    end
    last_ovh_ip
  end

  def setup_ip_override(ip, host_data, host)
    ipor = IpOverride.find_or_create_by(address: ip.address)
    ipor.traits_autonomous_system_number = ip.traits_autonomous_system_number
    ipor.country_iso_code = host_data[:country_iso_code]
    ipor.country_name = host_data[:country_name]
    ipor.city_name = host_data[:city_name]
    ipor.data_center_key = host_data[:data_center_key]
    ipor.data_center_host = host
    ipor.save
  end

  def update_ip_with_overrides
    sql1 = "
    UPDATE ips ip
    INNER JOIN ip_overrides ipor
    ON ip.address = ipor.address
    SET
    ip.traits_autonomous_system_number = ipor.traits_autonomous_system_number,
    ip.country_iso_code = ipor.country_iso_code,
    ip.country_name = ipor.country_name,
    ip.city_name = ipor.city_name,
    ip.data_center_key = ipor.data_center_key,
    ip.data_center_host = ipor.data_center_host,
    ip.traits_autonomous_system_organization = 'Hetzner Online GmbH',
    ip.updated_at = NOW();
    "
    Ip.connection.execute(sql1)
  end

  def update_validator_score_with_overrides
    sql2 = "
    UPDATE validator_score_v1s sc
    INNER JOIN ips ip
    ON sc.ip_address = ip.address
    SET sc.data_center_key = ip.data_center_key,
    sc.data_center_host = ip.data_center_host,
    sc.updated_at = NOW();
    "
    ValidatorScoreV1.connection.execute(sql2)
  end
end