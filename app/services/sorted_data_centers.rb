class SortedDataCenters

  def call
    @sort_by == 'data_center' ? sort_by_data_centers : sort_by_asn

    @results = @results.sort_by { |_k, v| -v[:active_stake] }
    {
      total_population: @total_population,
      total_stake: @total_stake,
      total_delinquent: @total_delinquent,
      results: @results
    }
  end

  def initialize(sort_by:, network:)
    @sort_by = sort_by
    sql = "
      SELECT DISTINCT
        ips.data_center_key,
        ips.traits_autonomous_system_number,
        ips.traits_autonomous_system_organization,
        ips.country_iso_code,
        SUM(IF(validator_score_v1s.delinquent = true, 1, 0)) as delinquent_count,
        IF(ISNULL(city_name), location_time_zone, city_name) as location
      FROM ips
      JOIN validator_score_v1s
      ON validator_score_v1s.ip_address = ips.address
      WHERE ips.address IN (
        SELECT score.ip_address
        FROM validator_score_v1s score
        WHERE score.network = ?
        AND score.active_stake > 0
      )
      GROUP BY
        ips.data_center_key,
        ips.traits_autonomous_system_number,
        ips.traits_autonomous_system_organization,
        ips.country_iso_code,
        location
      "
    @dc_sql = Ip.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql, [sql, network])
    )

    @scores = ValidatorScoreV1.where(network: network)
                              .where('active_stake > 0')

    @total_stake = @scores.sum(:active_stake)
    @total_population = 0
    @total_delinquent = 0
    @results = {}
  end

  def sort_by_asn
    @dc_sql = @dc_sql.group_by { |dc| dc[1] }
    @dc_sql.each do |dc|
      dc_keys = dc[1].map { |x| x[0] }
      aso = dc[1].map { |d| d[2] }.compact.uniq.join(', ')
      population = @scores.by_data_centers(dc_keys).count || 0
      active_stake = @scores.by_data_centers(dc_keys).sum(:active_stake)
      delinquent_validators = dc[1].inject(0) { |sum, el| sum + el[4] } || 0

      next if population.zero?

      @total_population += population
      @total_delinquent += delinquent_validators
      @results[dc[0]] = {
        asn: dc[0],
        aso: aso,
        data_centers: dc_keys,
        count: population,
        active_stake: active_stake,
        delinquent_validators: delinquent_validators
      }
    end
  end

  def sort_by_data_centers
    @dc_sql.each do |dc|
      population = @scores.by_data_centers(dc[0]).count || 0
      delinquent_validators = dc[4] || 0
      active_stake = @scores.by_data_centers(dc[0]).sum(:active_stake)

      next if population.zero?

      @total_population += population
      @total_delinquent += delinquent_validators

      @results[dc[0]] = {
        aso: dc[1],
        country: dc[2],
        location: dc[3],
        count: population,
        active_stake: active_stake,
        delinquent_validators: delinquent_validators,
      }
    end
  end
end
