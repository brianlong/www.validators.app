# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/assign_data_center_scores.rb >> /tmp/assign_data_center_scores.log 2>&1 &

require File.expand_path('../config/environment', __dir__)

sql = "
  SELECT distinct data_center_key,
         traits_autonomous_system_organization,
         country_iso_code,
         IF(ISNULL(city_name), location_time_zone, city_name) as location
  FROM ips
  WHERE ips.address IN (
    SELECT score.ip_address
    FROM validator_score_v1s score
    WHERE score.network = 'mainnet'
    AND score.active_stake > 0
  )
"
@dc_sql = Ip.connection.execute(sql)
@scores = ValidatorScoreV1.where(network: 'mainnet')
                          .where('active_stake > 0')
@data_centers = {}
@total_stake = @scores.sum(:active_stake)
@total_population = 0

@dc_sql.each do |dc|
  population = @scores.where(data_center_key: dc[0]).count || 0
  active_stake = @scores.where(data_center_key: dc[0]).sum(:active_stake)
  next if population.zero?

  @total_population += population

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

@data_centers.each do |k,v|
  if ((v[:active_stake] / @total_stake.to_f)*100.0) >= 33.0
    score = -2
  else
    score = 0
  end
  # puts "#{k} score = #{score}"
  score_sql = "UPDATE validator_score_v1s SET data_center_concentration_score = #{score} WHERE network = 'mainnet' AND data_center_key = '#{k}';"
  ValidatorScoreV1.connection.execute(score_sql)
end
