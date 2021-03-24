# frozen_string_literal: true

ovh_hosts = {
  'lon1-eri1' => {
    country_iso_code: 'EN',
    country_name: 'Great Britain',
    city_name: 'London',
    data_center_key: 'MK-16276-EN-London'
  },
  'bhs-g' => {
    country_iso_code: 'CA',
    country_name: 'Canada',
    city_name: 'Beauharnois',
    data_center_key: 'MK-16276-CA-Beauharnois'
  },
  'waw-d' => {
    country_iso_code: 'PL',
    country_name: 'Poland',
    city_name: 'Warsaw',
    data_center_key: 'MK-16276-PL-Warsaw'
  },
  'rbx-g' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Roubaix',
    data_center_key: 'MK-16276-FR-Paris'
  },
  'fra1-lim1' => {
    country_iso_code: 'DE',
    country_name: 'Germany',
    city_name: 'Frankfurt',
    data_center_key: 'MK-16276-FR-Paris'
  },
  'gra-' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Gravelines',
    data_center_key: 'MK-16276-FR-Gravelines'
  },
  'sbg-g' => {
    country_iso_code: 'FR',
    country_name: 'France',
    city_name: 'Strasbourg',
    data_center_key: 'MK-16276-FR-Strasbourg'
  }
}

total_done = 0

Ip.where(traits_autonomous_system_number: 16276).offset(29).each do |ip|
  traceroute =  `traceroute -m 20 #{ip.address}`.split("\n")
  last_ovh_ip = nil
  traceroute.each do |line|
    puts line
    next unless line.match?(/(be|bg|vl).+(lon1|rbx|bhs|waw|fra|gra|sbg).+/)
    last_ovh_ip = line
  end
  ovh_hosts.each do |k, v|
    next unless last_ovh_ip && last_ovh_ip.include?(k)
    puts v.inspect
    ipor = IpOverride.find_or_create_by(address: ip.address)
    ipor.traits_autonomous_system_number = ip.traits_autonomous_system_number
    ipor.country_iso_code = v[:country_iso_code]
    ipor.country_name = v[:country_name]
    ipor.city_name = v[:city_name]
    ipor.data_center_key = v[:data_center_key]
    host = last_ovh_ip.strip.split(" ")[1].strip
    puts host
    ipor.data_center_host = host
    ipor.save
    total_done += 1
  end
  puts total_done.to_s + " " + Ip.where(traits_autonomous_system_number: 16276).count.to_s
end

puts total_done.to_s + " " + Ip.where(traits_autonomous_system_number: 16276).count.to_s