# frozen_string_literal: true

module IpGeoCountryHelper
  def set_geo_country
    request.env["HTTP_CF_IPCOUNTRY"].to_s
  end
end
