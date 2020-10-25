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
        SELECT score.ip_address
        FROM validator_score_v1s score
        WHERE score.network = '#{params[:network]}'
        AND score.active_stake > 0
      )
    "
    @dc_sql = Ip.connection.execute(sql)
    @scores = ValidatorScoreV1.where(network: params[:network])
                              .where('active_stake > 0')
    @data_centers = {}
    @total_stake = @scores.sum(:active_stake)

    @dc_sql.each do |dc|
      population = @scores.where(data_center_key: dc[0]).count || 0
      active_stake = @scores.where(data_center_key: dc[0]).sum(:active_stake)
      next if population.zero?

      Rails.logger.info "#{dc.inspect} => #{population}"
      Rails.logger.info "Active Stake: #{active_stake}"
      # Rails.logger.info dc[0]
      # Rails.logger.info "@data_centers is a #{@data_centers.class}"
      # Rails.logger.info @data_centers[dc[0]]
      # Rails.logger.info (@data_centers[dc[0]]).to_s
      # byebug
      @data_centers[dc[0]] = {
        aso: dc[1],
        country: dc[2],
        location: dc[3],
        count: population,
        active_stake: active_stake
      }
      # Rails.logger.info @data_centers.inspect
    end
    @data_centers = @data_centers.sort_by { |_k, v| -v[:count] }
    # Rails.logger.info @data_centers
  end

  # params[:network]
  # params[:key]
  def data_center
    key = params[:key].gsub('-slash-', '/')
    # sql = "
    #   SELECT *
    #   FROM validators val
    #   INNER JOIN validator_score_v1s score ON val.id = score.validator_id
    #   WHERE score.network = '#{params[:network]}'
    #   AND score.active_stake > 0
    #   AND score.ip_address IN (
    #     SELECT ip_address from ips
    #     WHERE data_center_key = '#{key}'
    #   )
    #   ORDER BY val.account
    # "
    # @validators = Validator.connection.execute(sql)
    @scores = ValidatorScoreV1.where(network: params[:network])
                              .where(data_center_key: key)
                              .where('active_stake > 0')

    @total_stake = ValidatorScoreV1.where(network: params[:network])
                                   .where('active_stake > 0')
                                   .sum(:active_stake)
  end
end
