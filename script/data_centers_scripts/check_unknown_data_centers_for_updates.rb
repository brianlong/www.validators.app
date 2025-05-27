# frozen_string_literal: true
require_relative('../../config/environment')

unknown_data_center = DataCenter.find_by(data_center_key: DataCenter::UNKNOWN_DATA_CENTER_KEY)
if unknown_data_center.blank?
  puts "No Unkown Data Centers"
  return
end

unknown_ips = unknown_data_center.validator_ips
                                 .where(is_active: true, is_muted: false)
                                 .pluck(:address)
                                 .uniq
ip_service = DataCenters::CheckIpInfoService.new

unknown_ips.each do |ip|
  puts ip
  begin
    result = ip_service.call(ip: ip)
    puts "Private IP - skipping" if result == :skip
  rescue MaxMind::GeoIP2::Error => e
    puts "\nMaxMindError:"
    puts e.message
    puts e.backtrace
    puts "Going for next ip"
    next
  end
end
