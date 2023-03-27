# frozen_string_literal: true

class DataCenters::CheckIpInfoService

  PRIVATE_IP_REGEX = /(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/.freeze

  def initialize
    @client ||= MaxMindClient.new
  end

  def call(ip:)
    # Skip private IPs
    return :skip if !ip || ip.match?(PRIVATE_IP_REGEX)

    max_mind_info = get_max_mind_info(ip)

    data_center = set_data_center(max_mind_info)
    fill_blank_values(data_center, max_mind_info)
    data_center.save!

    update_validator_ips(ip, data_center, max_mind_info)
  end

  def get_max_mind_info(ip)
    @client.insights(ip)
  end

  def update_validator_ips(ip, data_center, max_mind_info)
    data_center_host = DataCenterHost.find_or_create_by!(
      data_center: data_center,
      host: nil
    )

    val_ips = ValidatorIp.where(
      is_active: true,
      address: ip
    )

    val_ips.each do |val_ip|
      val_ip.update!(
        data_center_host: data_center_host,
        traits_domain: max_mind_info.traits.domain,
        traits_ip_address: max_mind_info.traits.ip_address,
        traits_network: max_mind_info.traits.network
      )
    end
  end

  def set_data_center(max_mind_info)
    DataCenter.find_or_initialize_by(
      continent_code: max_mind_info.continent.code,
      continent_geoname_id: max_mind_info.continent.geoname_id,
      continent_name: max_mind_info.continent.name,
      country_iso_code: max_mind_info.country.iso_code,
      country_geoname_id: max_mind_info.country.geoname_id,
      country_name: max_mind_info.country.name,
      registered_country_iso_code: max_mind_info.registered_country.iso_code,
      registered_country_geoname_id: max_mind_info.registered_country.geoname_id,
      registered_country_name: max_mind_info.registered_country.name,
      traits_anonymous: max_mind_info.traits.anonymous?,
      traits_hosting_provider: max_mind_info.traits.hosting_provider?,
      traits_user_type: max_mind_info.traits.user_type,
      traits_autonomous_system_number: max_mind_info.traits.autonomous_system_number,
      traits_autonomous_system_organization: max_mind_info.traits.autonomous_system_organization,
      city_name: max_mind_info.city.name,
      location_metro_code: max_mind_info.location.metro_code,
      location_time_zone: max_mind_info.location.time_zone,
    )
  end

  def fill_blank_values(data_center, max_mind_info)
    # Change empty strings to nil
    data_center.normalize_empty_strings

    # This data cause duplicated data_center records
    data_center.city_confidence ||= max_mind_info.city.confidence
    data_center.city_geoname_id ||= max_mind_info.city.geoname_id
    data_center.country_confidence ||= max_mind_info.country.confidence
    data_center.location_accuracy_radius ||= max_mind_info.location.accuracy_radius
    data_center.location_average_income ||= max_mind_info.location.average_income
    data_center.location_latitude ||= max_mind_info.location.latitude
    data_center.location_longitude ||= max_mind_info.location.longitude
    data_center.location_population_density ||= max_mind_info.location.population_density
    data_center.postal_code ||= max_mind_info.postal.code
    data_center.postal_confidence ||= max_mind_info.postal.confidence
    data_center.traits_isp ||= max_mind_info.traits.isp
    data_center.traits_organization ||= max_mind_info.traits.organization

    unless max_mind_info.most_specific_subdivision.nil?
      data_center.subdivision_confidence ||= max_mind_info.most_specific_subdivision.confidence
      data_center.subdivision_iso_code ||= max_mind_info.most_specific_subdivision.iso_code
      data_center.subdivision_geoname_id ||= max_mind_info.most_specific_subdivision.geoname_id
      data_center.subdivision_name ||= max_mind_info.most_specific_subdivision.name
    end
  end
end
