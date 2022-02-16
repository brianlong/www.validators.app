# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/migrate_from_ips_to_data_centers/copy_data_to_data_centers.rb

require_relative '../../config/environment'

@file ||= File.open("tmp/copy_data_to_data_centers.txt", "w")

def create_data_center_from_ip(ip)
  data_center = DataCenter.find_or_create_by!(
    continent_code: ip.continent_code,
    continent_geoname_id: ip.continent_geoname_id,
    continent_name: ip.continent_name,
    country_confidence: ip.country_confidence,
    country_iso_code: ip.country_iso_code,
    country_geoname_id: ip.country_geoname_id,
    country_name: ip.country_name,
    data_center_host: ip.data_center_host,
    registered_country_iso_code: ip.registered_country_iso_code,
    registered_country_geoname_id: ip.registered_country_geoname_id,
    registered_country_name: ip.registered_country_name,
    traits_anonymous: ip.traits_anonymous,
    traits_hosting_provider: ip.traits_hosting_provider,
    traits_user_type: ip.traits_user_type,
    traits_autonomous_system_number: ip.traits_autonomous_system_number,
    traits_autonomous_system_organization: ip.traits_autonomous_system_organization,
    traits_domain: ip.traits_domain,
    traits_isp: ip.traits_isp,
    traits_organization: ip.traits_organization,
    city_confidence: ip.city_confidence,
    city_geoname_id: ip.city_geoname_id,
    city_name: ip.city_name,
    location_average_income: ip.location_average_income,
    location_population_density: ip.location_population_density,
    location_accuracy_radius: ip.location_accuracy_radius,
    location_latitude: ip.location_latitude,
    location_longitude: ip.location_longitude,
    location_metro_code: ip.location_metro_code,
    location_time_zone: ip.location_time_zone,
    postal_confidence: ip.postal_confidence,
    postal_code: ip.postal_code,
    subdivision_confidence: ip.subdivision_confidence,
    subdivision_iso_code: ip.subdivision_iso_code,
    subdivision_geoname_id: ip.subdivision_geoname_id,
    subdivision_name: ip.subdivision_name
  )

  @file.write "Data Center #{data_center.data_center_key} found or created.\n"
  data_center
end

def create_or_update_validator_ip(ip, data_center)
  val_ip = ValidatorIp.find_by(address: ip.address)

  if val_ip
    val_ip.update(
      data_center_id: data_center.id,
      traits_ip_address: ip.traits_ip_address,
      traits_network: ip.traits_network,
    )
    @file.write "Validator IP with id #{val_ip.id} updated with data center #{val_ip.data_center_id}: #{data_center.data_center_key}.\n"
  else
    val = ValidatorIp.create!(
      address: ip.address,
      data_center_id: data_center.id,
      traits_ip_address: ip.traits_ip_address,
      traits_network: ip.traits_network
    )

    @file.write "Validator IP created for address #{ip.address} with data center #{val.data_center_id}: #{data_center.data_center_key}.\n"
  end
end

### ### Ip overrirdes  ### ###

def update_validator_ip_from_ip_override(ip_override)
  val_ip = ValidatorIp.find_by(address: ip_override.address)
  ip = Ip.find_by(address: ip_override.address)
  data_center = DataCenter.find_by(
    traits_autonomous_system_number: ip_override.traits_autonomous_system_number,
    traits_autonomous_system_organization: ip_override.traits_autonomous_system_organization,
    country_iso_code: ip_override.country_iso_code,
    country_name: ip_override.country_name,
    data_center_key: ip_override.data_center_key,
    data_center_host: ip_override.data_center_host
  )

  if data_center && val_ip
    val_ip.update(is_overridden: true, data_center_id: data_center.id)

    @file.write "Validator IP with id: #{val_ip.id} 
                updated with data center id: #{data_center.id}, 
                data_center_key: #{ip_override.data_center_key},
                data_center_host: #{ip_override.data_center_host},
                is_overridden set to true.\n"
  else
    @file.write "Data center not found for
                  traits_autonomous_system_number: #{ip_override.traits_autonomous_system_number}, 
                  traits_autonomous_system_organization: #{ip_override.traits_autonomous_system_organization}, 
                  data_center_key: #{ip_override.data_center_key},
                  data_center_host: #{ip_override.data_center_host}.
                  ip_override: #{ip_override.id}.\n" unless data_center
    @file.write "Validator IP not found for id: #{ip_override.id}, ip address #{ip_override.address}.\n" unless ip_override
  end
end

Ip.find_in_batches do |batch|
  puts "Ips migration started..."
  batch.each do |ip|
    data_center = create_data_center_from_ip(ip)
    create_or_update_validator_ip(ip, data_center)
    @file.write "------------------------\n"
  end
end
puts "Ips migration finished."

IpOverride.find_in_batches do |batch|
  puts "Ip overrides updates started..."

  batch.each do |ip_override|
    update_validator_ip_from_ip_override(ip_override)
  end
end

puts "Updating validator_ips finished.\n"
puts "Check /tmp/copy_data_to_data_centers.txt for more info."
puts "Script is finished.\n"
