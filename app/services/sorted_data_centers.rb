class SortedDataCenters

  def call
    @sort_by == 'data_center' ? sort_by_data_centers : sort_by_asn

    @results = @results.sort_by { |_k, v| -v[:active_stake] }
    {
      total_population: @total_population,
      total_stake: @total_stake,
      results: @results
    }
  end

  def initialize(sort_by:, network:)
    @sort_by = sort_by
    sql = "
      SELECT distinct data_center_key,
            traits_autonomous_system_number,
            traits_autonomous_system_organization,
            country_iso_code,
            IF(ISNULL(city_name), location_time_zone, city_name) as location
      FROM ips
      WHERE ips.address IN (
        SELECT score.ip_address
        FROM validator_score_v1s score
        WHERE score.network = ?
        AND score.active_stake > 0
      )
    "
    @dc_sql = Ip.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql, [sql, network])
    )

    @scores = ValidatorScoreV1.where(network: network)
                              .where('active_stake > 0')

    @total_stake = @scores.sum(:active_stake)
    @total_population = 0
    @results = {}
  end

  def sort_by_asn
    @dc_sql = @dc_sql.group_by { |dc| dc[1] }
    @dc_sql.each do |dc|
      dc_keys = dc[1].map { |x| x[0] }
      population = @scores.by_data_centers(dc_keys).count || 0
      active_stake = @scores.by_data_centers(dc_keys).sum(:active_stake)
      next if population.zero?

      @total_population += population

      @results[dc[0]] = {
        asn: dc[0],
        aso: dc[1].map { |d| d[2] }.compact.uniq.join(', '),
        data_centers: dc_keys,
        count: population,
        active_stake: active_stake
      }
    end
  end

  def sort_by_data_centers
    @dc_sql.each do |dc|
      population = @scores.by_data_centers(dc[0]).count || 0
      active_stake = @scores.by_data_centers(dc[0]).sum(:active_stake)
      next if population.zero?

      @total_population += population

      @results[dc[0]] = {
        aso: dc[1],
        country: dc[2],
        location: dc[3],
        count: population,
        active_stake: active_stake
      }
    end
  end
end
