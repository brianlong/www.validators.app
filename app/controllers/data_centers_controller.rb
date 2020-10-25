class DataCentersController < ApplicationController
  # params[:network]
  def index
    sql = "
      SELECT distinct data_center_key,
             traits_autonomous_system_organization,
             country_iso_code,
             IF(ISNULL(city_name), location_time_zone, city_name) as location
      FROM ips
      WHERE ips.address IN (
        SELECT vip.address
        FROM validator_ips vip
        INNER JOIN validators val ON val.id = vip.validator_id
        WHERE val.network = '#{params[:network]}'
      )
    "
    @dc_sql = Ip.connection.execute(sql)
    @scores = ValidatorScoreV1.where(network: params[:network])
    @data_centers = {}
    @dc_sql.each do |dc|
      population = @scores.where(data_center_key: dc[0]).count || 0
      Rails.logger.info "#{dc.inspect} => #{population}"
      Rails.logger.info dc[0]
      Rails.logger.info "@data_centers is a #{@data_centers.class}"
      Rails.logger.info @data_centers[dc[0]]
      Rails.logger.info (@data_centers[dc[0]]).to_s
      # byebug
      @data_centers[dc[0]] = {
        aso: dc[1],
        country: dc[2],
        location: dc[3],
        count: population
      }
      Rails.logger.info @data_centers.inspect
    end
    @data_centers = @data_centers.sort_by { |_k, v| -v[:count] }
    Rails.logger.info @data_centers
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
