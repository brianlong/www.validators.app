# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/append_ip_geo_data.rb
require File.expand_path('../config/environment', __dir__)
require 'json'
require 'net/http'
require 'uri'
require 'maxmind/geoip2'

# dev_mode = true # change to false for production

begin
  interrupted = false
  trap('INT') { interrupted = true }

  # Setup the MaxMind client
  client = MaxMind::GeoIP2::Client.new(
    account_id: Rails.application.credentials.max_mind[:account_id],
    license_key: Rails.application.credentials.max_mind[:license_key]
  )

  # Search for the IP
  record = client.insights('167.172.16.90')

  puts ''
  puts record.inspect
  puts ''

  puts 'Continent:'
  puts record.continent.code
  puts record.continent.geoname_id
  puts record.continent.name

  puts 'Country:'
  puts record.country.confidence
  puts record.country.iso_code
  puts record.country.geoname_id
  puts record.country.name

  puts 'Registered Country:'
  puts record.registered_country.iso_code
  puts record.registered_country.geoname_id
  puts record.registered_country.name

  # Represented Country
  # puts record.represented_country

  puts 'Traits:'
  puts record.traits.anonymous?
  puts record.traits.hosting_provider?
  puts record.traits.user_type
  puts record.traits.autonomous_system_number
  puts record.traits.autonomous_system_organization
  puts record.traits.domain
  puts record.traits.isp
  puts record.traits.organization
  puts record.traits.ip_address
  puts record.traits.network

  puts 'City:'
  puts record.city.confidence
  puts record.city.geoname_id
  puts record.city.name

  puts 'Location:'
  puts record.location.average_income
  puts record.location.population_density
  puts record.location.accuracy_radius
  puts record.location.latitude
  puts record.location.longitude
  puts record.location.metro_code
  puts record.location.time_zone

  puts 'Postal:'
  puts record.postal.confidence
  puts record.postal.code
  puts ''

  puts 'Subdivision:'
  puts record.most_specific_subdivision.confidence
  puts record.most_specific_subdivision.iso_code
  puts record.most_specific_subdivision.geoname_id
  puts record.most_specific_subdivision.name

  puts 'MaxMind:'
  puts record.maxmind.queries_remaining

  # puts 'Updated proxy_ips/max_mind_insights.txt'
rescue StandardError => e
  puts "\nERROR:"
  puts e.message
  puts e.backtrace
  puts ''
end
