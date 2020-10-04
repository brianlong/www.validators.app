class DataCentersController < ApplicationController
  def index
    sql = "
      SELECT data_center_key,
             traits_autonomous_system_organization,
             country_iso_code,
             IF(ISNULL(city_name), location_time_zone, city_name) as location,
             count(*) as count
      FROM ips
      WHERE ips.address IN (
        SELECT vip.address
        FROM validator_ips vip
        INNER JOIN validators val ON val.id = vip.validator_id
        WHERE val.network = '#{params[:network]}'
      )
      GROUP BY data_center_key,
               country_iso_code,
               location,
               traits_autonomous_system_organization
      ORDER BY count desc
    "
    @data_centers = Ip.connection.execute(sql)
  end
end
