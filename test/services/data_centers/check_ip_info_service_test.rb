# frozen_string_literal: true

require "test_helper"

module DataCenters
  class CheckIpInfoServiceTest < ActiveSupport::TestCase
    include VcrHelper

    setup do
      @namespace = File.join("services", "data_centers", "check_ip_info_service_test")

      @validator_ips = ["146.59.55.140", "146.59.71.20", "141.94.248.167"].map do |ip|
        create(:validator_ip, :active, address: ip)
      end

      @service = CheckIpInfoService.new
    end

    test ".call creates DataCenter and updates validator_ips" do
      assert_difference ["DataCenter.count", "DataCenterHost.count"], 1 do
        vcr_cassette(@namespace, __method__) do
          @service.call(ip: "146.59.71.20")
        end

        # Check DataCenter
        data_center = DataCenter.find_by(
          data_center_key: "16276-FR-Europe/Paris",
          continent_name: "Europe",
          country_name:"France",
          traits_isp: "OVH SAS"
        )

        assert data_center
        assert_equal 48.8582, data_center.location_latitude
        assert_equal 2.3387, data_center.location_longitude

        # Check DataCenterHost
        data_host = data_center.data_center_hosts.last
        assert data_host

        # Check ValidatorIp
        validator_ip = ValidatorIp.find_by_address "146.59.71.20"

        assert validator_ip
        assert_equal data_host, validator_ip.data_center_host
        assert_equal "ip-146-59-71.eu", validator_ip.traits_domain
        assert_equal "146.59.71.0/24", validator_ip.traits_network
      end
    end

    test ".call updates existing DataCenter and updates validator_ips" do
      data_center = create(
        :data_center,
        continent_code: "EU",
        continent_geoname_id: 6255148,
        continent_name: "Europe",
        country_iso_code: "FR",
        country_geoname_id: 3017382,
        country_name: "France",
        registered_country_iso_code: "FR",
        registered_country_geoname_id: 3017382,
        registered_country_name: "France",
        traits_anonymous: true,
        traits_hosting_provider: true,
        traits_user_type: "hosting",
        traits_autonomous_system_number: 16276,
        traits_autonomous_system_organization: "OVH SAS",
        city_name: nil,
        location_metro_code: nil,
        location_time_zone: "Europe/Paris",
        traits_isp: "  "
      )
      data_host = create(:data_center_host, data_center: data_center, host: nil)

      assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
        vcr_cassette(@namespace, __method__) do
          @service.call(ip: "141.94.248.167")
        end

        # Check DataCenter
        data_center.reload
        assert_equal 48.8582, data_center.location_latitude
        assert_equal 2.3387, data_center.location_longitude
        assert_equal "OVH SAS", data_center.traits_isp

        # Check DataCenterHost
        data_host = data_center.data_center_hosts.last
        data_host.reload

        # Check ValidatorIp
        validator_ip = ValidatorIp.find_by_address "141.94.248.167"

        assert validator_ip
        assert_equal data_host, validator_ip.data_center_host
        assert_equal "ip-141-94-248.eu", validator_ip.traits_domain
        assert_equal "141.94.248.0/24", validator_ip.traits_network
      end
    end

    test ".call doesn't create data center or host, and updates is_muted attribute, when ip is private" do
      ["10.255.20.255", "10.10.20.255", "172.16.1.0", "192.168.1.12"].each do |ip|
        validator_ip = create(:validator_ip, :active, address: ip)
        assert_equal validator_ip.is_muted, false

        assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
          assert_equal :skip, @service.call(ip: ip)
        end
        assert_equal validator_ip.reload.is_muted, true
      end
    end

    test ".call doesn't create data center or host, and updates is_muted attribute, when ASN is empty" do
      ["16.82.185.159", "140.5.57.160"].each do |ip|
        validator_ip = create(:validator_ip, :active, address: ip)
        assert_equal validator_ip.is_muted, false

        assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
          vcr_cassette(@namespace, __method__) do
            @service.call(ip: ip)
          end
        end
        assert_equal validator_ip.reload.is_muted, true
      end
    end

    test ".call doesn't create data center or host, and updates is_muted attribute, when ip is invalid" do
      validator_ip = create(:validator_ip, :active, address: "243.84.161.29")
      assert_equal validator_ip.reload.is_muted, false

      assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
        vcr_cassette(@namespace, __method__) do
          @service.call(ip: validator_ip.address)
        end
      end
      assert_equal validator_ip.reload.is_muted, true
    end

    test ".call uses autonomous_system_organization as fallback for blank traits_isp and traits_organization" do
      validator_ip = create(:validator_ip, :active, address: "1.2.3.4")
      
      # Mock MaxMind response with blank isp and organization
      mock_traits = OpenStruct.new(
        autonomous_system_number: 12345,
        autonomous_system_organization: "Fallback ASO Name",
        isp: nil,
        organization: "",
        anonymous?: false,
        hosting_provider?: true,
        user_type: "hosting",
        domain: nil,
        ip_address: "1.2.3.4",
        network: "1.2.3.0/24"
      )
      mock_continent = OpenStruct.new(code: "EU", geoname_id: 6255148, name: "Europe")
      mock_country = OpenStruct.new(iso_code: "DE", geoname_id: 2921044, name: "Germany", confidence: 99)
      mock_registered_country = OpenStruct.new(iso_code: "DE", geoname_id: 2921044, name: "Germany")
      mock_city = OpenStruct.new(name: "Berlin", confidence: 80, geoname_id: 2950159)
      mock_location = OpenStruct.new(
        time_zone: "Europe/Berlin",
        latitude: 52.5200,
        longitude: 13.4050,
        metro_code: nil,
        accuracy_radius: 10,
        average_income: nil,
        population_density: nil
      )
      mock_postal = OpenStruct.new(code: "10115", confidence: 20)
      
      mock_maxmind_info = OpenStruct.new(
        traits: mock_traits,
        continent: mock_continent,
        country: mock_country,
        registered_country: mock_registered_country,
        city: mock_city,
        location: mock_location,
        postal: mock_postal,
        most_specific_subdivision: nil
      )

      @service.stub :get_max_mind_info, mock_maxmind_info do
        assert_difference "DataCenter.count", 1 do
          @service.call(ip: "1.2.3.4")
        end

        data_center = DataCenter.last
        assert_equal "Fallback ASO Name", data_center.traits_isp
        assert_equal "Fallback ASO Name", data_center.traits_organization
        assert_equal "Fallback ASO Name", data_center.traits_autonomous_system_organization
      end
    end
  end
end
