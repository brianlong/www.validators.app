# frozen_string_literal: true

class DataCenters::CheckIpInfoService

  def initialize(ip: )
    @ip = ip
    @client ||= MaxMindClient.new
  end

  def call
    puts @ip.inspect

    # Skip private IPs
    regexp_for_private_ips = /(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/
    return nil if @ip.match?(regexp_for_private_ips)

    record = @client.insights(@ip)

    data_center = DataCenter.find_or_initialize_by(
      continent_code: record.continent.code,
      continent_geoname_id: record.continent.geoname_id,
      continent_name: record.continent.name,
      country_iso_code: record.country.iso_code,
      country_geoname_id: record.country.geoname_id,
      country_name: record.country.name,
      registered_country_iso_code: record.registered_country.iso_code,
      registered_country_geoname_id: record.registered_country.geoname_id,
      registered_country_name: record.registered_country.name,
      traits_anonymous: record.traits.anonymous?,
      traits_hosting_provider: record.traits.hosting_provider?,
      traits_user_type: record.traits.user_type,
      traits_autonomous_system_number: record.traits.autonomous_system_number,
      traits_autonomous_system_organization: record.traits.autonomous_system_organization,
      city_name: record.city.name,
      location_metro_code: record.location.metro_code,
      location_time_zone: record.location.time_zone,
    )

    # This data cause duplicated data_center records
    data_center.city_confidence = record.city.confidence if data_center.city_confidence.blank?
    data_center.city_geoname_id = record.city.geoname_id if data_center.city_geoname_id.blank?
    data_center.country_confidence = record.country.confidence if record.country.confidence.blank?
    data_center.location_accuracy_radius = record.location.accuracy_radius if data_center.location_accuracy_radius.blank?
    data_center.location_average_income = record.location.average_income if data_center.location_average_income.blank?
    data_center.location_latitude = record.location.latitude if data_center.location_latitude.blank?
    data_center.location_longitude = record.location.longitude if data_center.location_longitude.blank?
    data_center.location_population_density = record.location.population_density if data_center.location_population_density.blank?
    data_center.postal_code = record.postal.code if data_center.postal_code.blank?
    data_center.postal_confidence = record.postal.confidence if data_center.postal_confidence.blank?
    data_center.traits_isp = record.traits.isp if data_center.traits_isp.blank?
    data_center.traits_organization = record.traits.organization if data_center.traits_organization.blank?

    unless record.most_specific_subdivision.nil?
      data_center.subdivision_confidence = record.most_specific_subdivision.confidence if data_center.subdivision_confidence.blank?
      data_center.subdivision_iso_code = record.most_specific_subdivision.iso_code if data_center.subdivision_iso_code.blank?
      data_center.subdivision_geoname_id = record.most_specific_subdivision.geoname_id if data_center.subdivision_geoname_id.blank?
      data_center.subdivision_name = record.most_specific_subdivision.name if data_center.subdivision_name.blank?
    end
    
    data_center.save!

    data_center_host = DataCenterHost.find_or_create_by!(
      data_center: data_center,
      host: nil
    )

    val_ips = ValidatorIp.where(
      is_active: true, 
      address: @ip
    )

    val_ips.each do |val_ip|
      val_ip.update(
        data_center_host: data_center_host,
        traits_domain: record.traits.domain, 
        traits_ip_address: record.traits.ip_address,
        traits_network: record.traits.network
      )
    end
  end
end
