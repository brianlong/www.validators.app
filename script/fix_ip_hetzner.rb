# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/append_ip_geo_data.rb
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
    data_center_key: '24940-Fi-Helsinki'
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

Ip.where(traits_autonomous_system_number: 24_940).each do |ip|
  puts ''
  puts "Tracing #{ip.address}"
  # Grab a traceroute to look for the data center host record.
  # e.g. ex9k1.dc5.fsn1.hetzner.com
  traceroute =  `traceroute -m 20 #{ip.address}`.split("\n")
  traceroute.each do |line|
    puts ".  #{line}"
  end
  puts ''
end
