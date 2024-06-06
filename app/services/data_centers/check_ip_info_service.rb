# frozen_string_literal: true

class DataCenters::CheckIpInfoService
  class MissingAsnError < StandardError; end

  PRIVATE_IP_REGEX = /(^127\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^192\.168\.)/.freeze

  def initialize
    @client ||= MaxMindClient.new
    @logger = Logger.new("#{Rails.root}/log/check_ip_info_service.log")
  end

  def call(ip:)
    # Skip private IPs
    if !ip || ip.match?(PRIVATE_IP_REGEX)
      mute_validator_ips(ip)
      return :skip
    end

    max_mind_info = get_max_mind_info(ip)

    raise MissingAsnError if max_mind_info.traits.autonomous_system_number.blank?

    data_center = set_data_center(max_mind_info)

    fill_blank_values(data_center, max_mind_info)

    update_validator_ips(ip, data_center, max_mind_info) if data_center.save
  rescue MaxMind::GeoIP2::AddressReservedError => e
    @logger.info("MaxMind::GeoIP2::AddressReservedError: error for #{ip}")
    mute_validator_ips(ip)
    Appsignal.send_error(e)
  rescue MissingAsnError => e
    @logger.info("MissingAsnError: missing ASN for #{ip}")
    mute_validator_ips(ip)
    Appsignal.send_error(e)
  rescue StandardError => e
    @logger.info("Error for #{ip}: #{e.message}")
    Appsignal.send_error(e)
  end

  def get_max_mind_info(ip)
    @client.insights(ip)
  end

  def update_validator_ips(ip, data_center, max_mind_info)
    data_center_host = DataCenterHost.find_or_create_by(
      data_center: data_center,
      host: nil
    )

    val_ips = ValidatorIp.where(
      is_active: true,
      address: ip
    )

    val_ips.each do |val_ip|
      val_ip.update(
        data_center_host: data_center_host,
        traits_domain: max_mind_info.traits.domain,
        traits_ip_address: max_mind_info.traits.ip_address,
        traits_network: max_mind_info.traits.network
      )
    end
  end

  def set_data_center(max_mind_info)
    DataCenter.find_or_initialize_by(
      traits_autonomous_system_number: max_mind_info.traits.autonomous_system_number,
      country_iso_code: unified_country_code(max_mind_info.country.iso_code),
      city_name: max_mind_info.city.name,
      location_time_zone: max_mind_info.location.time_zone,
    )
  end

  def fill_blank_values(data_center, max_mind_info)
    # Change empty strings to nil
    data_center.normalize_empty_strings

    # This data cause duplicated data_center records
    data_center.continent_code = max_mind_info.continent.code unless max_mind_info.continent.code.blank?
    data_center.continent_geoname_id = max_mind_info.continent.geoname_id \
      unless max_mind_info.continent.geoname_id.blank?
    data_center.continent_name = max_mind_info.continent.name unless max_mind_info.continent.name.blank?
    data_center.country_geoname_id = max_mind_info.country.geoname_id unless max_mind_info.country.geoname_id.blank?
    data_center.country_name = unified_country(max_mind_info.country.name) \
      unless unified_country(max_mind_info.country.name).blank?
    data_center.registered_country_iso_code = unified_country_code(max_mind_info.registered_country.iso_code) \
      unless unified_country_code(max_mind_info.registered_country.iso_code).blank?
    data_center.registered_country_geoname_id = max_mind_info.registered_country.geoname_id \
      unless max_mind_info.registered_country.geoname_id.blank?
    data_center.registered_country_name = unified_country(max_mind_info.registered_country.name) \
      unless unified_country(max_mind_info.registered_country.name).blank?
    data_center.traits_anonymous = max_mind_info.traits.anonymous?
    data_center.traits_hosting_provider = max_mind_info.traits.hosting_provider?
    data_center.traits_user_type = max_mind_info.traits.user_type unless max_mind_info.traits.user_type.blank?
    data_center.traits_autonomous_system_organization = max_mind_info.traits.autonomous_system_organization \
      unless max_mind_info.traits.autonomous_system_organization.blank?
    data_center.location_metro_code = max_mind_info.location.metro_code unless max_mind_info.location.metro_code.blank?
    data_center.city_confidence = max_mind_info.city.confidence unless max_mind_info.city.confidence.blank?
    data_center.city_geoname_id = max_mind_info.city.geoname_id unless max_mind_info.city.geoname_id.blank?
    data_center.country_confidence = max_mind_info.country.confidence unless max_mind_info.country.confidence.blank?
    data_center.location_accuracy_radius = max_mind_info.location.accuracy_radius \
      unless max_mind_info.location.accuracy_radius.blank?
    data_center.location_average_income = max_mind_info.location.average_income \
      unless max_mind_info.location.average_income.blank?
    data_center.location_latitude = max_mind_info.location.latitude unless max_mind_info.location.latitude.blank?
    data_center.location_longitude = max_mind_info.location.longitude unless max_mind_info.location.longitude.blank?
    data_center.location_population_density = max_mind_info.location.population_density \
      unless max_mind_info.location.population_density.blank?
    data_center.postal_code = max_mind_info.postal.code unless max_mind_info.postal.code.blank?
    data_center.postal_confidence = max_mind_info.postal.confidence unless max_mind_info.postal.confidence.blank?
    data_center.traits_isp = max_mind_info.traits.isp unless max_mind_info.traits.isp.blank?
    data_center.traits_organization = max_mind_info.traits.organization unless max_mind_info.traits.organization.blank?

    unless max_mind_info.most_specific_subdivision.nil?
      data_center.subdivision_confidence ||= max_mind_info.most_specific_subdivision.confidence
      data_center.subdivision_iso_code ||= max_mind_info.most_specific_subdivision.iso_code
      data_center.subdivision_geoname_id ||= max_mind_info.most_specific_subdivision.geoname_id
      data_center.subdivision_name ||= max_mind_info.most_specific_subdivision.name
    end
  end

  def unified_country_code(code)
    code == "EN" ? "GB" : code
  end

  def unified_country(country)
    ["great britain", "england"].include?(country&.downcase) ? "United Kingdom" : country
  end

  def mute_validator_ips(ip)
    ValidatorIp.where(is_active: true, address: ip).each do |val_ip|
      val_ip.update(is_muted: true)
    end
  end
end
