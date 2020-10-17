class DataCentersController < ApplicationController
  # params[:network]
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
    @scores = ValidatorScoreV1.where(network: params[:network])
  end

  # params[:network]
  # params[:key]
  def data_center
    key = params[:key].gsub('-slash-', '/')
    sql = "
      SELECT *
      FROM validators val
      INNER JOIN validator_ips vip ON val.id = vip.validator_id
      WHERE val.network = '#{params[:network]}'
      AND vip.address IN (
        SELECT address from ips
        WHERE data_center_key = '#{key}'
      )
      ORDER BY val.account
    "
    @validators = Validator.connection.execute(sql)
    @scores = ValidatorScoreV1.where(network: params[:network])
                              .where(data_center_key: key)
  end
end
