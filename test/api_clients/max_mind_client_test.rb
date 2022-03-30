# frozen_string_literal: true

require "test_helper"

module ApiClients
  class MaxMindClientTest < ActiveSupport::TestCase
    include VcrHelper

    setup do
      @ip = "185.191.127.144"
      @service = MaxMindClient.new
      @vcr_namespace ||= File.join("api_clients", "max_mind_client_test")
    end

    test "#insights when correct ip is passed returns all ip information from maxmind" do
      vcr_cassette(@vcr_namespace, "correct_ip") do
        insights = @service.insights(@ip)

        assert_equal "EU", insights.continent.code
        assert_equal 6255148, insights.continent.geoname_id
        assert_equal "Europe", insights.continent.name
        assert_equal "NL", insights.country.iso_code
        assert_equal 2750405, insights.country.geoname_id
        assert_equal "Netherlands", insights.country.name
        assert_equal "SC", insights.registered_country.iso_code
        assert_equal 241170, insights.registered_country.geoname_id
        assert_equal "Seychelles", insights.registered_country.name
        assert_equal false, insights.traits.anonymous?
        assert_equal false, insights.traits.hosting_provider?
        assert_equal "residential", insights.traits.user_type
        assert_equal 206264, insights.traits.autonomous_system_number
        assert_equal "Amarutu Technology Ltd", insights.traits.autonomous_system_organization
        assert_equal "Amsterdam", insights.city.name
        assert_nil   insights.location.metro_code
        assert_equal "Europe/Amsterdam", insights.location.time_zone
        assert_equal 1, insights.city.confidence
        assert_equal 2759794, insights.city.geoname_id
        assert_equal 99, insights.country.confidence
        assert_equal 50, insights.location.accuracy_radius
        assert_nil   insights.location.average_income
        assert_equal 52.3759, insights.location.latitude
        assert_equal 4.8975, insights.location.longitude
        assert_nil   insights.location.population_density
        assert_equal "1012", insights.postal.code
        assert_equal 1, insights.postal.confidence
        assert_equal "Amarutu Technology Ltd", insights.traits.isp
        assert_equal "Amarutu Technology Ltd", insights.traits.organization
        assert_equal 1, insights.most_specific_subdivision.confidence
        assert_equal "NH", insights.most_specific_subdivision.iso_code
        assert_equal 2749879, insights.most_specific_subdivision.geoname_id
        assert_equal "North Holland", insights.most_specific_subdivision.name

        # Not used by us for now but might be useful.
        assert_equal "185.191.127.144", insights.traits.ip_address
        assert_equal "185.191.127.144/32", insights.traits.network
      end
    end
  end
end
