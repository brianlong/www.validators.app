# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/fix_ip_hetzner.rb >> /tmp/fix_ip_hetzner.log 2>&1 &

require File.expand_path('../config/environment', __dir__)

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
    # puts ".  #{line}"
    next unless line.match?(/ex.+\.dc.+\.hetzner\.com/) ||
                line.match?(/sp.+\.cloud.+\.hetzner\.com/)

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
  sql = "
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
    ip.updated_at = NOW();
  "
  Ip.connection.execute(sql)
  puts ''
end
