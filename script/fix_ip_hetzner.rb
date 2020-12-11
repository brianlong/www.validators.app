# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/fix_ip_hetzner.rb >> /tmp/fix_ip_hetzner.log 2>&1 &

require File.expand_path('../config/environment', __dir__)

aso = 'Hetzner Online GmbH'
hetzner_hosts = {
  'fsn1.hetzner.com' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Falkenstein',
    data_center_key: '24940-DE-Falkenstein'
  },
  'nbg1.hetzner.com' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Nuremburg',
    data_center_key: '24940-DE-Nuremburg'
  },
  'hel.hetzner.com' => {
    country_iso_code: 'FI',
    country_name: 'Finland',
    city_name: 'Helsinki',
    data_center_key: '24940-FI-Helsinki'
  },
  'hel1.hetzner.com' => {
    country_iso_code: 'FI',
    country_name: 'Finland',
    city_name: 'Helsinki',
    data_center_key: '24940-FI-Helsinki'
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

Ip.where(traits_autonomous_system_number: 24_940)
  .where('address not in (select address from ip_overrides)')
  .each do |ip|
  puts ''
  puts "Tracing #{ip.address}"
  # Grab a traceroute to look for the data center host record.
  # e.g. ex9k1.dc5.fsn1.hetzner.com
  traceroute =  `traceroute -m 20 #{ip.address}`.split("\n")
  traceroute.each do |line|
    puts ".  #{line}"
    next unless line.match?(/ex.+\.dc.+\.hetzner\.com/) ||
                line.match?(/sp.+\.cloud.+\.hetzner\.com/)
    # use the lines below for some tough-to-get addresses
    # ||
    # line.match?(/core.+\.[hfn].+\.hetzner\.com/)

    puts "M  #{line}"
    hetzner_hosts.each do |k, v|
      next unless line.include?(k)

      puts "   #{v.inspect}"
      ipor = IpOverride.find_or_create_by(address: ip.address)
      ipor.traits_autonomous_system_number = ip.traits_autonomous_system_number
      ipor.country_iso_code = v[:country_iso_code]
      ipor.country_name = v[:country_name]
      ipor.city_name = v[:city_name]
      ipor.data_center_key = v[:data_center_key]
      host = line.match(/(\sex.+\.dc.+\.hetzner\.com\s)/)[1].strip.split(' ')[0] \
             if line.match?(/(\sex.+\.dc.+\.hetzner\.com)/)
      host = line.match(/(\ssp.+\.cloud.+\.hetzner\.com)/)[1].strip.split(' ')[0] \
             if line.match?(/(\ssp.+\.cloud.+\.hetzner\.com)/)
      ipor.data_center_host = host
      ipor.save
      break
    end

    # More stuff here
    break
  end
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

  sql2 = "
    UPDATE validator_score_v1s sc
    INNER JOIN ips ip
    ON sc.ip_address = ip.address
    SET sc.data_center_key = ip.data_center_key,
    sc.updated_at = NOW();
  "
  ValidatorScoreV1.connection.execute(sql2)
  puts ''
end
puts 'End of Script'
