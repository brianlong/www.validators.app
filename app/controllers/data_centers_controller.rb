class DataCentersController < ApplicationController
  def index
    sql = "
      SELECT data_center_key,
             traits_autonomous_system_organization,
             country_iso_code,
             IF(ISNULL(city_name), location_time_zone, city_name) as location,
             count(*) as count
      FROM ips
      GROUP BY data_center_key,
               country_iso_code,
               location,
               traits_autonomous_system_organization
      ORDER BY count desc
    "
    @data_centers = Ip.connection.execute(sql)
  end
end
