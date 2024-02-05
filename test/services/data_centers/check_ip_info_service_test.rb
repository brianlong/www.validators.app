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
        vcr_cassette(@namespace, "valid_maxmind_request") do
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

    test ".call doesn't do anything when ip is private" do
      assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
        assert_equal :skip, @service.call(ip: "10.255.20.255")
        assert_equal :skip, @service.call(ip: "10.10.20.255")
        assert_equal :skip, @service.call(ip: "172.16.1.0")
        assert_equal :skip, @service.call(ip: "192.168.1.12")
      end
    end

    test ".call doesn't do anything for invalid ip_address" do
      assert_no_difference ["DataCenter.count", "DataCenterHost.count"] do
        vcr_cassette(@namespace, __method__) do
          assert_raise(MaxMind::GeoIP2::AddressInvalidError) do
            @service.call(ip: "743.123.46.21")
          end
        end
      end
    end

    test ".call returns DataCenters::CheckIpInfoService::BlankAutonomousSystemNumberError if ASN is blank" do
      vcr_cassette(@namespace, "valid_maxmind_request") do
        mock = Minitest::Mock.new({ autonomous_system_number: nil })
        mock.expect :autonomous_system_number, nil

        MaxMind::GeoIP2::Record::Traits.stub(:new, mock) do
          assert_raise ::DataCenters::CheckIpInfoService::BlankAutonomousSystemNumberError do
            @service.call(ip: "146.59.71.20")
          end
        end
      end
    end
  end
end

