class SortedDataCenters
  def initialize(sort_by:, network:, secondary_sort: 'stake')
    @sort_by = sort_by
    @network = network
    @secondary_sort = secondary_sort

    select_statement = [
      "data_centers.data_center_key",
      "data_centers.traits_autonomous_system_number",
      "data_centers.traits_autonomous_system_organization",
      "data_centers.country_iso_code",
      "SUM(IF(validator_score_v1s.delinquent = true, 1, 0)) as delinquent_count",
      "IF(ISNULL(city_name), location_time_zone, city_name) as location",
      "SUM(IF(validators.is_active = true, validator_score_v1s.active_stake, 0)) as active_stake_from_active_validators",
      "SUM(validator_score_v1s.active_stake) as total_active_stake",
      "COUNT(*) as total_validator_score_v1s",
    ]

    group = [
      "data_centers.data_center_key", 
      "data_centers.traits_autonomous_system_number",
      "data_centers.traits_autonomous_system_organization", 
      "data_centers.country_iso_code", 
      "location"
    ]

    # Private validators are only for mainnet
    # so we don't need this count on testnet.
    private_validators_count = "SUM(IF(validator_score_v1s.commission = 100, 1, 0)) as private_count"

    select_statement << private_validators_count if @network == "mainnet"

    @dc_sql = DataCenter.select(select_statement)
                        .joins(validator_score_v1s: :validator)
                        .where(
                          "validator_score_v1s.network = ? \
                          AND validator_score_v1s.active_stake > ? \
                          AND validators.is_active = true",
                          @network, 0
                        )
                        .group(group)

    @total_stake = @dc_sql.inject(0) { |sum, dc| sum + dc.total_active_stake }
    @total_active_stake_from_active_validators = @dc_sql.inject(0) { |sum, dc| sum + dc.active_stake_from_active_validators }
    @total_population = 0
    @total_delinquent = 0
    @total_private = 0
    @results = {}
  end

  def call
    @sort_by == 'data_center' ? sort_by_data_centers : sort_by_asn
    if @secondary_sort == 'stake'
      @results = @results.sort_by { |_k, v| -v[:active_stake_from_active_validators] }
    else
      @results = @results.sort_by { |_k, v| -v[:count] }
    end

    result_hash = {
      total_population: @total_population,
      total_delinquent: @total_delinquent,
      total_stake: @total_stake,
      total_active_stake_from_active_validators: @total_active_stake_from_active_validators,
      results: @results
    }

    result_hash.merge!({total_private: @total_private}) if @network == "mainnet"

    result_hash
  end

  def sort_by_asn
    @dc_sql = @dc_sql.group_by { |dc| dc.traits_autonomous_system_number }

    @dc_sql.each do |data_center_key, data_centers|
      next if data_center_key.blank?

      dc_keys = data_centers.map { |dc| dc.data_center_key }
      aso = data_centers.map { |dc| dc.traits_autonomous_system_organization }.compact.uniq.join(', ')
      population = data_centers.inject(0) { |sum, dc| sum + dc.total_validator_score_v1s } || 0
      delinquent_validators = data_centers.inject(0) { |sum, dc| sum + dc.delinquent_count } || 0
      active_stake_from_all_validators = data_centers.inject(0) { |sum, dc| sum + dc.total_active_stake }
      active_stake_from_active_validators = data_centers.inject(0) { |sum, dc| sum + dc.active_stake_from_active_validators } || 0

      next if population.zero?

      @total_population += population
      @total_delinquent += delinquent_validators
      @results[data_center_key] = {
        asn: data_center_key,
        aso: aso,
        data_centers: dc_keys,
        count: population,
        delinquent_validators: delinquent_validators,
        active_stake_from_active_validators: active_stake_from_active_validators,
        active_stake_from_all_validators: active_stake_from_all_validators
      }

      # We count private validators only for mainnet.
      if @network == 'mainnet'
        private_validators = data_centers.inject(0) { |sum, dc| sum + dc.private_count } || 0
        @total_private += private_validators
        @results[data_center_key].merge!({ private_validators: private_validators })
      end
    end
  end

  def sort_by_data_centers
    @dc_sql.each do |dc|
      data_center_key = dc.data_center_key
      population = dc.total_validator_score_v1s || 0
      delinquent_validators = dc.delinquent_count || 0
      active_stake_from_active_validators = dc.active_stake_from_active_validators || 0
      active_stake_from_all_validators = dc.total_active_stake || 0

      next if population.zero?

      @total_population += population
      @total_delinquent += delinquent_validators

      @results[data_center_key] = {
        aso: dc.traits_autonomous_system_number,
        country: dc.traits_autonomous_system_organization,
        location: dc.country_iso_code,
        count: population,
        delinquent_validators: delinquent_validators,
        active_stake_from_all_validators: active_stake_from_all_validators,
        active_stake_from_active_validators: active_stake_from_active_validators
      }

      # We count private validators only for mainnet.
      if @network == 'mainnet'
        private_validators = dc&.private_count || 0
        @total_private += private_validators
        @results[data_center_key].merge!({ private_validators: private_validators })
      end
    end
  end
end
