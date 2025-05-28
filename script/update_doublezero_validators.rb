# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)
require 'uri'
require 'net/http'

uri = URI("https://kobe.mainnet.jito.network/api/v1/validators")
response = Net::HTTP.get_response(uri)

DOUBLEZERO_IPS = [
  '15.235.228.93', '64.130.49.117', '45.250.255.163', '38.97.60.51', '69.67.151.19', '45.63.111.115', '45.77.142.108', '81.16.184.251',
  '64.130.52.205', '195.12.227.249', '208.91.110.197', '198.244.165.235', '209.38.103.172', '85.195.100.119', '69.67.149.97',
  '103.50.32.128', '72.46.84.221', '67.213.120.9', '65.20.100.233', '37.122.252.22', '57.128.64.53', '104.237.53.202', '64.130.49.181',
  '207.121.26.12', '64.130.52.201', '72.46.87.231', '202.8.9.28', '64.130.52.140', '46.17.103.70', '81.16.188.250', '88.211.249.212',
  '5.255.78.21', '65.20.105.212', '64.130.52.135', '88.216.198.169', '81.16.188.251', '64.130.32.133', '160.202.131.117',
  '136.244.108.105', '23.109.62.84', '192.69.209.194', '188.214.130.71', '208.91.107.71', '8.244.152.28', '185.92.120.151',
  '149.28.255.82', '147.28.165.79', '177.54.154.15', '64.130.58.6', '144.168.36.130'
]

logger = Logger.new('log/update_doublezero_validators.log')
logger.info("Updating DoubleZero validators...")

doublezero_validators_ids = []

begin
  DOUBLEZERO_IPS.each do |ip_address|
    ValidatorIp.where(is_active: true, address: ip_address).find_each do |validator_ip|
      next unless validator_ip.validator_id.present?

      doublezero_validators_ids << validator_ip.validator_id
    end
  end

  Validator.where.not(id: doublezero_validators_ids).update_all(is_dz: false)
  Validator.where(id: doublezero_validators_ids).update_all(is_dz: true)

  logger.info("DoubleZero validators updated successfully: #{doublezero_validators_ids}")
rescue StandardError => e
  logger.error("Failed to update DoubleZero validators: #{e}")
  Appsignal.send_error(e)
end
