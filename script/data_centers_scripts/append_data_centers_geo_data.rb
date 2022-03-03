# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/append_data_centers_geo_data.rb
require_relative '../../config/environment'
require 'json'
require 'net/http'
require 'uri'
require 'maxmind/geoip2'

begin
  interrupted = false
  trap('INT') { interrupted = true }  unless Rails.env.test?

  verbose = true # Rails.env == 'development'

  # Setup the MaxMind client
  client = MaxMind::GeoIP2::Client.new(
    account_id: Rails.application.credentials.max_mind[:account_id],
    license_key: Rails.application.credentials.max_mind[:license_key]
  )

  # SQL statement to find un-appended IPs
  sql = "SELECT DISTINCT address
         FROM validator_ips v
         WHERE v.data_center_host_id IS NULL"

  sql = "#{sql} LIMIT 10" if Rails.env == 'development'

  ValidatorIp.connection.execute(sql).each do |missing_ip|
    puts missing_ip[0].inspect if verbose

    # Skip private IPs
    next if missing_ip[0].match(/^(10|192|127)\..+/).present?

    record = client.insights(missing_ip[0])

    data_center = DataCenter.find_or_initialize_by(
      continent_code: record.continent.code,
      continent_geoname_id: record.continent.geoname_id,
      continent_name: record.continent.name,
      country_iso_code: record.country.iso_code,
      country_geoname_id: record.country.geoname_id,
      country_name: record.country.name,
      registered_country_iso_code: record.registered_country.iso_code,
      registered_country_geoname_id: record.registered_country.geoname_id,
      registered_country_name: record.registered_country.name,
      traits_anonymous: record.traits.anonymous?,
      traits_hosting_provider: record.traits.hosting_provider?,
      traits_user_type: record.traits.user_type,
      traits_autonomous_system_number: record.traits.autonomous_system_number,
      traits_autonomous_system_organization: record.traits.autonomous_system_organization,
      city_name: record.city.name,
      location_metro_code: record.location.metro_code,
      location_time_zone: record.location.time_zone,
    )

    # This data cause duplicated data_center records
    data_center.city_confidence = record.city.confidence if data_center.city_confidence.blank?
    data_center.city_geoname_id = record.city.geoname_id if data_center.city_geoname_id.blank?
    data_center.country_confidence = record.country.confidence if record.country.confidence.blank?
    data_center.location_accuracy_radius = record.location.accuracy_radius if data_center.location_accuracy_radius.blank?
    data_center.location_average_income = record.location.average_income if data_center.location_average_income.blank?
    data_center.location_latitude = record.location.latitude if data_center.location_latitude.blank?
    data_center.location_longitude = record.location.longitude if data_center.location_longitude.blank?
    data_center.location_population_density = record.location.population_density if data_center.location_population_density.blank?
    data_center.postal_code = record.postal.code if data_center.postal_code.blank?
    data_center.postal_confidence = record.postal.confidence if data_center.postal_confidence.blank?
    data_center.traits_isp = record.traits.isp if data_center.traits_isp.blank?
    data_center.traits_organization = record.traits.organization if data_center.traits_organization.blank?

    unless record.most_specific_subdivision.nil?
      data_center.subdivision_confidence = record.most_specific_subdivision.confidence if data_center.subdivision_confidence.blank?
      data_center.subdivision_iso_code = record.most_specific_subdivision.iso_code if data_center.subdivision_iso_code.blank?
      data_center.subdivision_geoname_id = record.most_specific_subdivision.geoname_id if data_center.subdivision_geoname_id.blank?
      data_center.subdivision_name = record.most_specific_subdivision.name if data_center.subdivision_name.blank?
    end
    
    data_center.save!

    data_center_host = DataCenterHost.find_or_create_by!(
      data_center: data_center,
      host: nil
    )

    val_ip = ValidatorIp.find_by(address: missing_ip.first)
    val_ip.update(
      data_center_host: data_center_host,
      traits_domain: record.traits.domain, 
      traits_ip_address: record.traits.ip_address,
      traits_network: record.traits.network
    )
  end

  puts '' if verbose
  # Update validator_score_v1s with the latest data
  ValidatorScoreV1.find_each do |vs1|
    next unless vs1.validator && vs1.validator&.ip_address

    validator = vs1.validator
    validator_ip = validator.validator_ips.order('updated_at desc').first

    ip = validator_ip.address

    vs1.network = validator.network
    vs1.ip_address = ip
    unless validator_ip.data_center_host.nil?
      vs1.data_center_key = validator_ip.data_center_host.data_center_key
    end
    vs1.save
  end

  # Clean up the scores table to remove data_center_host if the node moved out
  # of Hetzner
  ValidatorScoreV1.connection.execute(
    "update validator_score_v1s set data_center_host = null where data_center_key not like '24940%' and data_center_host is not null;"
  )

rescue StandardError => e
  puts "\nERROR:"
  puts e.message
  puts e.backtrace
  puts ''
end
