# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/append_data_centers_geo_data.rb
require_relative '../../config/environment'
require 'json'
require 'net/http'
require 'uri'

begin
  interrupted = false
  trap('INT') { interrupted = true }  unless Rails.env.test?

  verbose = true # Rails.env == 'development'

  # SQL statement to find un-appended IPs
  sql = "SELECT DISTINCT address
         FROM validator_ips v
         WHERE v.is_active = true
         AND v.data_center_host_id IS NULL"

  sql = "#{sql} LIMIT 10" if Rails.env == 'development'

  ValidatorIp.connection.execute(sql).each do |missing_ip|
    DataCenters::CheckIpInfoService.new(ip: missing_ip[0]).call
  end

  puts '' if verbose
  # Update validator_score_v1s with the latest data
  ValidatorScoreV1.find_each do |vs1|
    next unless vs1.validator && vs1.validator&.validator_ip_active&.address

    validator = vs1.validator
    validator_ip = validator.validator_ip_active

    next unless validator_ip

    ip = validator_ip.address

    vs1.network = validator.network
    vs1.ip_address = ip
    
    vs1.save
  end

rescue StandardError => e
  puts "\nERROR:"
  puts e.message
  puts e.backtrace
  puts ''
end
