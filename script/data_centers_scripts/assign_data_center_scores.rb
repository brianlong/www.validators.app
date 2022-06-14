# frozen_string_literal: true

# RAILS_ENV=production bundle exec ruby script/data_centers_scripts/assign_data_center_scores.rb >> /tmp/assign_data_center_scores.log 2>&1 &

require_relative '../../config/environment'

MAX_DATA_CENTER_STAKE = 10.0
where_clause = "validator_ips.is_active = ? AND validator_score_v1s.network = ? AND validator_score_v1s.active_stake > ?"
dch_ids = ValidatorIp.select('validator_ips.data_center_host_id')
                     .joins(validator: [:validator_score_v1])
                     .where(where_clause, true, 'mainnet', 0)
                     .pluck(:data_center_host_id)
                     .compact
                     .uniq
                     
data_center_hosts = DataCenterHost.includes(:data_center).where(id: dch_ids)

@scores = ValidatorScoreV1.joins(:data_center)
                          .where(network: 'mainnet')
                          .where('active_stake > 0')
@data_centers = {}
@total_stake = @scores.sum(:active_stake)
@total_population = 0

data_center_hosts.each do |dch|
  dc = dch.data_center

  population = @scores.where("data_centers.data_center_key = ?", dch.data_center_key).count || 0
  active_stake = @scores.where("data_centers.data_center_key = ?", dch.data_center_key).sum(:active_stake)
  next if population.zero?

  @total_population += population

  @data_centers[dc.data_center_key] = {
    aso: dc.traits_autonomous_system_organization,
    country: dc.country_iso_code,
    location: dc.city_name || dc.location_time_zone,
    count: population,
    active_stake: active_stake
  }
end

@data_centers = @data_centers.sort_by { |_k, v| -v[:count] }
@data_centers.each do |k, v|
  if ((v[:active_stake] / @total_stake.to_f)*100.0) >= MAX_DATA_CENTER_STAKE
    score = -2
  else
    score = 0
  end

  validator_score_v1s = ValidatorScoreV1.by_data_centers(k).where(network: 'mainnet')
  validator_score_v1s.update(data_center_concentration_score: score)
end
