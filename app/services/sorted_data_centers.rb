class SortedDataCenters

  def call
    @sort_by == 'data_center' ? sort_by_data_centers : sort_by_asn

    @results = @results.sort_by { |_k, v| -v[:active_stake] }
    result_hash = {
      total_population: @total_population,
      total_stake: @total_stake,
      total_delinquent: @total_delinquent,
      results: @results
    }

    result_hash.merge!({total_private: @total_private}) if @network == 'mainnet'

    result_hash
  end

  def initialize(sort_by:, network:)
    @sort_by = sort_by
    @network = network

    select_statement = [
      "ips.data_center_key",
      "ips.traits_autonomous_system_number",
      "ips.traits_autonomous_system_organization",
      "ips.country_iso_code",
      'SUM(IF(validator_score_v1s.delinquent = true, 1, 0)) as delinquent_count',
      "IF(ISNULL(city_name), location_time_zone, city_name) as location"
    ]

    # Private validators are only for mainnet
    # so we don't need this count on testnet.
    private_validators_count = "SUM(IF(validator_score_v1s.commission = 100, 1, 0)) as private_count"

    select_statement << private_validators_count if @network == 'mainnet'

    sql = "
      SELECT DISTINCT
        #{select_statement.join(', ')}
      FROM ips
      JOIN validator_score_v1s
      ON validator_score_v1s.ip_address = ips.address
      WHERE ips.address IN (
        SELECT score.ip_address
        FROM validator_score_v1s score
        WHERE score.network = ?
        AND score.active_stake > 0
      )
      AND validator_score_v1s.network = ?
      GROUP BY
        ips.data_center_key,
        ips.traits_autonomous_system_number,
        ips.traits_autonomous_system_organization,
        ips.country_iso_code,
        location
      "

    @dc_sql = Ip.connection.execute(
      ActiveRecord::Base.send(:sanitize_sql, [sql, @network, @network])
    )

    @scores = ValidatorScoreV1.where(network: @network)
                              .where('active_stake > 0')

    @total_stake = @scores.sum(:active_stake)
    @total_population = 0
    @total_delinquent = 0
    @total_private = 0
    @results = {}
  end

  def sort_by_asn
    @dc_sql = @dc_sql.group_by { |dc| dc[1] }
    @dc_sql.each do |dc|
      next if dc[0].blank?
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

      # We count private validators only for mainnet.
      if @network == 'mainnet'
        private_validators = dc[1].inject(0) { |sum, el| sum + el[6] } || 0
        @total_private += private_validators
        @results[dc[0]].merge!({ private_validators: private_validators })
      end
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
        delinquent_validators: delinquent_validators
      }

      # We count private validators only for mainnet.
      if @network == 'mainnet'
        private_validators = dc[6] || 0
        @total_private += private_validators
        @results[dc[0]].merge!({ private_validators: private_validators })
      end
    end
  end
end
