# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/migrate_from_ips_to_data_centers/copy_data_to_data_centers.rb

require_relative '../../config/environment'
log_path = Rails.root.join('log', 'copy_data_to_data_centers.log')
@logger ||= Logger.new(log_path)

def create_data_center_with_host_from_ip(ip)
  data_center = DataCenter.find_or_initialize_by(
    continent_code: ip.continent_code,
    continent_geoname_id: ip.continent_geoname_id,
    continent_name: ip.continent_name,
    country_iso_code: ip.country_iso_code,
    country_geoname_id: ip.country_geoname_id,
    country_name: ip.country_name,
    registered_country_iso_code: ip.registered_country_iso_code,
    registered_country_geoname_id: ip.registered_country_geoname_id,
    registered_country_name: ip.registered_country_name,
    traits_anonymous: ip.traits_anonymous,
    traits_hosting_provider: ip.traits_hosting_provider,
    traits_user_type: ip.traits_user_type,
    traits_autonomous_system_number: ip.traits_autonomous_system_number,
    traits_autonomous_system_organization: ip.traits_autonomous_system_organization,
    city_name: ip.city_name,
    location_metro_code: ip.location_metro_code,
    location_time_zone: ip.location_time_zone
  )

  # This data cause duplicated data_center records
  data_center.city_confidence = ip.city_confidence if data_center.city_confidence.blank?
  data_center.city_geoname_id = ip.city_geoname_id if data_center.city_geoname_id.blank?
  data_center.country_confidence = ip.country_confidence if data_center.country_confidence.blank?
  data_center.location_accuracy_radius = ip.location_accuracy_radius if data_center.location_accuracy_radius.blank?
  data_center.location_average_income = ip.location_average_income if data_center.location_average_income.blank?
  data_center.location_latitude = ip.location_latitude if data_center.location_latitude.blank?
  data_center.location_longitude = ip.location_longitude if data_center.location_longitude.blank?
  data_center.location_population_density = ip.location_population_density if data_center.location_population_density.blank?
  data_center.postal_code = ip.postal_code if data_center.postal_code.blank?
  data_center.postal_confidence = ip.postal_confidence if data_center.postal_confidence.blank?
  data_center.subdivision_confidence = ip.subdivision_confidence if data_center.subdivision_confidence.blank?
  data_center.subdivision_geoname_id = ip.subdivision_geoname_id if data_center.subdivision_geoname_id.blank?
  data_center.subdivision_iso_code = ip.subdivision_iso_code if data_center.subdivision_iso_code.blank?
  data_center.subdivision_name = ip.subdivision_name if data_center.subdivision_name.blank?
  data_center.traits_isp = ip.traits_isp if data_center.traits_isp.blank?
  data_center.traits_organization = ip.traits_organization if data_center.traits_organization.blank?

  data_center.save!

  data_center_host = DataCenterHost.find_or_create_by!(
    host: ip.data_center_host,
    data_center: data_center
  )

  info = <<-EOS 
    Data Center #{data_center.data_center_key} found or created (id: #{data_center.id}), 
    data_center_host #{data_center_host.host} (id: #{data_center_host.id}) assigned.
  EOS
  @logger.info info.squish
  
  data_center_host
end

def create_or_update_validator_ip(ip, data_center_host)
  val_ips = ValidatorIp.where(address: ip.address)
  val_ips.each do |val_ip|
    if val_ip
      val_ip.update(
        data_center_host_id: data_center_host.id,
        traits_ip_address: ip.traits_ip_address,
        traits_network: ip.traits_network,
        traits_domain: ip.traits_domain
      )
      info = <<-EOS
        Validator IP with id #{val_ip.id} updated with data_center_host_id: #{val_ip.data_center_host_id} 
        assigned to data center: #{data_center_host.data_center_key}.
      EOS
      @logger.info info.squish
    else
      validator_score_v1 = ip.validator_score_v1
      validator = validator_score_v1.validator

      val_ip = ValidatorIp.create!(
        address: ip.address,
        data_center_host_id: data_center_host.id,
        traits_ip_address: ip.traits_ip_address,
        traits_network: ip.traits_network,
        traits_domain: ip.traits_domain,
        validator_id: validator.id
      )

      info = <<-EOS
        Validator IP created for address #{ip.address} with data_center_host_id: #{val_ip.data_center_host_id} 
        assigned to data center: #{data_center_host.data_center_key}.
      EOS
      @logger.info info.squish
    end
  end
end

### ### Ip overrirdes  ### ###

def update_validator_ip_from_ip_override(ip_override)
  val_ip = ValidatorIp.find_by(address: ip_override.address)
  ip = Ip.find_by(address: ip_override.address)

  data_center = DataCenter.find_or_create_by!(
    traits_autonomous_system_number: ip_override.traits_autonomous_system_number,
    traits_autonomous_system_organization: ip_override.traits_autonomous_system_organization,
    country_iso_code: ip_override.country_iso_code,
    country_name: ip_override.country_name,
    data_center_key: ip_override.data_center_key
  )

  data_center_host = DataCenterHost.find_or_create_by!(
    host: ip_override.data_center_host,
    data_center: data_center
  )

  if data_center_host && val_ip
    val_ip.update(is_overridden: true, data_center_host_id: data_center_host.id)

    info = <<-EOS 
      \n
      Validator IP with id: #{val_ip.id} 
      updated with data_center_host  #{ip_override.data_center_host}, id: #{data_center_host.id},
      ip_override.data_center_key: #{ip_override.data_center_key}, data_center.data_center_key: #{data_center.data_center_key}
      is_overridden set to true."
    EOS
    @logger.info info
  else
    unless data_center_host
      warn = <<-EOS
        "Data center host not found for
        host: #{ip_override.data_center_host}.
        ip_override: #{ip_override.id}.\n" 
      EOS
      @logger.warn warn
    end
    
    @logger.warn "Validator IP not found for id: #{ip_override.id}, ip address #{ip_override.address}.\n" unless ip_override
  end
end

val_ip_addresses_empty_host = ValidatorIp.where(data_center_host: nil).pluck(:address)

Ip.where(address: val_ip_addresses_empty_host).find_in_batches do |batch|
  puts "Ips migration started..."
  batch.each do |ip|
    data_center_host = create_data_center_with_host_from_ip(ip)
    create_or_update_validator_ip(ip, data_center_host)
    @logger.debug "------------------------\n"
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
puts "Check log/copy_data_to_data_centers.txt for more info."
puts "Script is finished.\n"
