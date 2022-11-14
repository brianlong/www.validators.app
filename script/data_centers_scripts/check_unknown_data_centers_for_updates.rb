# frozen_string_literal: true
require_relative('../../config/environment')

unknown_data_center = DataCenter.find_by(data_center_key: DataCenter::UNKNOWN_DATA_CENTER_KEY)
return if unknown_data_center.blank?

unknown_validator_ips = unknown_data_center.validator_ips
ip_service = DataCenters::CheckIpInfoService.new

unknown_validator_ips.each do |validator_ip|
  ip_service.call(ip: validator_ip)
end
