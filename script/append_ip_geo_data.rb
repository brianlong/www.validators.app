# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/append_ip_geo_data.rb
require File.expand_path('../config/environment', __dir__)
require 'json'
require 'net/http'
require 'uri'
require 'maxmind/geoip2'

begin
  interrupted = false
  trap('INT') { interrupted = true }

  # Setup the MaxMind client
  client = MaxMind::GeoIP2::Client.new(
    account_id: Rails.application.credentials.max_mind[:account_id],
    license_key: Rails.application.credentials.max_mind[:license_key]
  )

  # SQL statement to find un-appended IPs
  sql = "SELECT DISTINCT address
         FROM validator_ips v
         WHERE v.address NOT IN (
           SELECT ips.address FROM ips
          )
         "
  sql = "#{sql} LIMIT 10" if Rails.env == 'development'

  Ip.connection.execute(sql).each do |missing_ip|
    puts missing_ip[0].inspect if Rails.env == 'development'
    # Skip private IPs
    next if missing_ip[0][0..2] == '10.'
    next if missing_ip[0][0..3] == '192.'

    record = client.insights(missing_ip[0])
    ip = Ip.create(
      address: missing_ip[0],
      continent_code: record.continent.code,
      continent_geoname_id: record.continent.geoname_id,
      continent_name: record.continent.name,
      country_confidence: record.country.confidence,
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
      traits_domain: record.traits.domain,
      traits_isp: record.traits.isp,
      traits_organization: record.traits.organization,
      traits_ip_address: record.traits.ip_address,
      traits_network: record.traits.network,
      city_confidence: record.city.confidence,
      city_geoname_id: record.city.geoname_id,
      city_name: record.city.name,
      location_average_income: record.location.average_income,
      location_population_density: record.location.population_density,
      location_accuracy_radius: record.location.accuracy_radius,
      location_latitude: record.location.latitude,
      location_longitude: record.location.longitude,
      location_metro_code: record.location.metro_code,
      location_time_zone: record.location.time_zone,
      postal_confidence: record.postal.confidence,
      postal_code: record.postal.code
    )
    next if record.most_specific_subdivision.nil?

    ip.subdivision_confidence = record.most_specific_subdivision.confidence
    ip.subdivision_iso_code = record.most_specific_subdivision.iso_code
    ip.subdivision_geoname_id = record.most_specific_subdivision.geoname_id
    ip.subdivision_name = record.most_specific_subdivision.name
    ip.save
  end

  puts '' if Rails.env == 'development'
  # Update validator_score_v1s with the latest data
  ValidatorScoreV1.find_each do |vs1|
    next unless vs1.validator && vs1.validator&.ip_address

    ip = vs1.validator.ip_address
    puts ip if Rails.env == 'development'

    vs1.network = vs1.validator.network
    vs1.ip_address = ip
    if Ip.where(address: ip).first
      vs1.data_center_key = Ip.where(address: ip).first.data_center_key
    end
    vs1.save
  end
rescue StandardError => e
  puts "\nERROR:"
  puts e.message
  puts e.backtrace
  puts ''
end

# puts ''
# puts record.inspect
# puts ''
#
# puts 'Continent:'
# puts record.continent.code
# puts record.continent.geoname_id
# puts record.continent.name
# puts ''
#
# puts 'Country:'
# puts record.country.confidence
# puts record.country.iso_code
# puts record.country.geoname_id
# puts record.country.name
# puts ''
#
# puts 'Registered Country:'
# puts record.registered_country.iso_code
# puts record.registered_country.geoname_id
# puts record.registered_country.name
# puts ''
#
# # Represented Country
# # puts record.represented_country
#
# puts 'Traits:'
# puts record.traits.anonymous?
# puts record.traits.hosting_provider?
# puts record.traits.user_type
# puts record.traits.autonomous_system_number
# puts record.traits.autonomous_system_organization
# puts record.traits.domain
# puts record.traits.isp
# puts record.traits.organization
# puts record.traits.ip_address
# puts record.traits.network
# puts ''
#
# puts 'City:'
# puts record.city.confidence
# puts record.city.geoname_id
# puts record.city.name
# puts ''
#
# puts 'Location:'
# puts record.location.average_income
# puts record.location.population_density
# puts record.location.accuracy_radius
# puts record.location.latitude
# puts record.location.longitude
# puts record.location.metro_code
# puts record.location.time_zone
# puts ''
#
# puts 'Postal:'
# puts record.postal.confidence
# puts record.postal.code
# puts ''
# puts ''
#
# puts 'Subdivision:'
# puts record.most_specific_subdivision.confidence
# puts record.most_specific_subdivision.iso_code
# puts record.most_specific_subdivision.geoname_id
# puts record.most_specific_subdivision.name
# puts ''
#
# puts 'MaxMind:'
# puts record.maxmind.queries_remaining
# puts ''

# puts 'Updated proxy_ips/max_mind_insights.txt'
