# frozen_string_literal: true

unknown_data_center = DataCenter.find_by(data_center_key: DataCenter::UNKNOWN_DATA_CENTER_KEY)
unknown_validator_ips = unknown_data_center.validator_ips

unknown_validator_ips.each do |validator_ip|
  DataCenters::CheckIpInfoService.new(ip: validator_ip.address).call
end
