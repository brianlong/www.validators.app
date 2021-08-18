# frozen_string_literal: true

module AsnLogic
  include PipelineLogic

  def gather_asns
    lambda do |p|
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
        ActiveRecord::Base.send(:sanitize_sql, [sql, p.payload[:network]])
      )
      asns = Ip.where(network: p.payload[:network])
               .distinct
               .pluck(:traits_autonomous_system_number)

      Pipeline.new(200, p.payload.merge(asns: asns))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from gather_asns', e)
    end
  end

  def prepare_stats
    
  end

  def calculate_data
    
  end

  def save_data
    
  end
end
