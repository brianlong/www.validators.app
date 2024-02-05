# frozen_string_literal: true
require_relative('../../config/environment')

unknown_data_center = DataCenter.find_by(data_center_key: DataCenter::UNKNOWN_DATA_CENTER_KEY)
if unknown_data_center.blank?
  puts "No Unkown Data Centers"
  return
end

unknown_validator_ips = unknown_data_center.validator_ips
ip_service = DataCenters::CheckIpInfoService.new

unknown_validator_ips.each do |validator_ip|
  puts validator_ip.address
  begin
    result = ip_service.call(ip: validator_ip.address)
    puts "Private IP - skipping" if result == :skip
  rescue MaxMind::GeoIP2::Error => e
    puts "\nMaxMindError:"
    puts e.message
    puts e.backtrace
    puts "Going for next ip"
    next
  rescue BlankAutonomousSystemNumberError
    puts "Blank ASN for IP - skipping"
    next
  end
end
