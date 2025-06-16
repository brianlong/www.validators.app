# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

DOUBLEZERO_IPS = [
  "69.67.149.97", "72.46.84.221", "64.130.52.140", "81.16.184.251", "65.19.161.132", "64.130.32.77", "207.121.26.12", "64.130.52.201", "38.129.137.238",
  "23.109.62.84", "67.213.120.9", "64.130.53.71", "64.130.49.117", "136.244.108.105", "31.172.68.190", "93.115.25.190", "72.46.87.231", "208.91.107.71",
  "70.34.211.174", "160.202.131.117", "202.8.9.28", "88.211.249.212", "67.209.52.136", "195.12.228.194", "65.20.105.212", "46.17.103.70", "64.130.32.242",
  "144.168.36.130", "147.28.165.79", "64.130.32.133", "5.255.78.21", "195.12.227.249", "198.244.165.235", "185.92.120.151", "45.77.142.108", "89.111.15.150",
  "64.130.52.205", "192.69.209.194", "189.1.171.173", "85.195.100.119", "209.38.103.172", "64.130.52.135", "57.128.64.53", "23.92.79.26", "69.67.151.19",
  "65.20.100.233", "104.237.53.202", "188.214.130.97", "37.122.252.22", "213.163.64.140", "194.126.172.242", "177.54.159.47", "149.28.255.82", "81.16.188.251",
  "188.214.130.71", "208.91.110.197", "194.126.172.174", "64.130.49.67", "64.130.49.181", "8.244.152.28", "88.216.197.27", "66.206.2.170", "15.235.228.93",
  "38.97.60.51", "64.130.58.6", "45.250.255.163", "103.50.32.128", "103.106.59.199", "81.16.188.250", "89.42.231.199", "88.216.198.169", "45.63.111.115", "177.54.154.15"
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
