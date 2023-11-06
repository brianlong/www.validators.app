# frozen_string_literal: true

module IpGeoCountryHelper
  def set_geo_country
    db = MaxMindDB.new("./GeoLite2-Country.mmdb")
    db.lookup(request.remote_ip).country.iso_code
    # db.lookup("102.129.157." + rand(1..255).to_s).country.iso_code # => "GB"
  end
end
