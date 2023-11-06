#frozen_string_literal: true

require "test_helper"

class IpGeoCountryHelperTest < ActionDispatch::IntegrationTest
  include IpGeoCountryHelper

  test "#set_geo_country returns a country code" do
    self.remote_addr = "102.129.157.124"
    get "/"
    assert_equal "GB", set_geo_country
  end
end
