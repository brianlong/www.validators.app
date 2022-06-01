module FixIpModule
  # look for the data center host record
  # returns line from traceroute or nil
  def get_matching_traceroute(ip:, reg:)
    traceroute =  `traceroute -m 20 #{ip}`.split("\n")
    last_ovh_ip = nil
    traceroute.each do |line|
      next unless line.match?(reg)

      # furthest ovh ip from traceroute
      last_ovh_ip = line
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

  # I think that data_center_key and host should be removed later 
  # because this information is in the data_center and data_center_host table
  def update_validator_score_with_overrides
    ValidatorScoreV1.in_batches(of: 50).each do |scores|
      ids = scores.pluck(:id)

      ValidatorScoreV1.includes(validator_ips: [data_center_host: [:data_center]])
                      .where(id: ids)
                      .each do |vs1|
        
        vip = ValidatorIp.find_by(address: vs1.ip_address, is_active: true)

        # Check that again
        next if vip.blank?

        data_center_host = vip.data_center_host

        # Check that again
        next if data_center_host.blank?

        vs1.update(
          data_center_key: data_center_host.data_center_key,
          updated_at: Time.now
        )
      end
    end
  end
end
