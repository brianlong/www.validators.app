module FixDataCenterModule
  # look for the data center host record
  # returns line from traceroute or nil
  def get_matching_traceroute(ip:, reg:, hops_number: 20)
    traceroute = `mtr -m #{hops_number} #{ip} --json`
    traceroute = JSON.parse(traceroute)
    last_ovh_ip = nil

    return nil unless traceroute["report"] && traceroute["report"]["hubs"]
    
    traceroute["report"]["hubs"].each do |line|
      next unless line["host"].match?(reg)

      # furthest ovh ip from traceroute
      last_ovh_ip = line["host"]
    end
    last_ovh_ip
  end

  # update or create new DataCenter and DataCenterHost with host data
  def setup_data_center(vip:, host_data:, host:)
    traits_autonomous_system_number = vip.data_center.traits_autonomous_system_number

    data_center = DataCenter.find_or_create_by(
      traits_autonomous_system_number: traits_autonomous_system_number,
      traits_autonomous_system_organization: host_data[:aso],
      country_iso_code: host_data[:country_iso_code],
      country_name: host_data[:country_name],
      city_name: host_data[:city_name],
      data_center_key: host_data[:data_center_key]
    ) # that's all the data we have from host_data

    data_center_host = DataCenterHost.find_or_create_by(
      host: host,
      data_center: data_center
    )
    
    puts "new host #{host} assigned to vip: #{vip.id} (data_center_host id: #{data_center_host.id})"

    vip.update(data_center_host: data_center_host, is_overridden: true)
  end
end
