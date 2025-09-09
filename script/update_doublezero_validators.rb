# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

logger = Logger.new('log/update_doublezero_validators.log')
file_path = Rails.root.join('storage', 'doublezero_users.txt')

doublezero_ips = []
doublezero_validators_ids = []

ip_regexp = /(?:[0-9]{1,3}\.){3}[0-9]{1,3}/

logger.info("Starting script...")

unless Rails.env.test?
  # Remove old file if exists and create a new one
  File.delete(file_path) if File.exist?(file_path)
  fork { exec("doublezero user list > #{file_path}") }
  Process.wait
end

begin
  unless File.exist?(file_path)
    logger.error("Doublezero file not found at: #{file_path}")
    return
  end

  logger.info("Processing doublezero users file")
  file = File.open(file_path, "r")
  file.each do |line|
    ip_address = line.scan(ip_regexp)&.first
    doublezero_ips << ip_address if ip_address
  end
  file.close

  logger.info("Found #{doublezero_ips.uniq.size} IPs")
  logger.info("Looking for validators")

  doublezero_ips.uniq.each do |ip_address|
    ValidatorIp.where(is_active: true, address: ip_address).find_each do |validator_ip|
      next unless validator_ip.validator_id.present?

      doublezero_validators_ids << validator_ip.validator_id
    end
  end

  Validator.where.not(id: doublezero_validators_ids).update_all(is_dz: false)
  Validator.where(id: doublezero_validators_ids).update_all(is_dz: true)

  logger.info("DoubleZero validators (#{doublezero_validators_ids.size}) updated successfully: #{doublezero_validators_ids}")
rescue StandardError => e
  logger.error("Failed to update DoubleZero validators: #{e}")
  Appsignal.send_error(e)
end
