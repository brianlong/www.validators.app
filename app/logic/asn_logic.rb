# frozen_string_literal: true

module AsnLogic
  include PipelineLogic

  def gather_asns
    lambda do |p|
      distinct_data_centers = Ip.connection.execute(
        ActiveRecord::Base.send(:sanitize_sql, [ips_sql, p.payload[:network]])
      )

      sorted_by_asn = distinct_data_centers.group_by { |dc| dc[1] }

      Pipeline.new(200, p.payload.merge(asns: sorted_by_asn))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from gather_asns', e)
    end
  end

  def gather_scores
    lambda do |p|
      scores = ValidatorScoreV1.where(network: p.payload[:network]).to_a

      Pipeline.new(200, p.payload.merge(scores: scores))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from gather_scores', e)
    end
  end

  def prepare_asn_stats
    lambda do |p|
      asn_stats = []

      p.payload[:asns].each do |asn, data|
        stat = AsnStat.find_or_create_by(
          traits_autonomous_system_number: asn,
          network: p.payload[:network]
        )
        stat.data_centers = []
        data.each do |d|
          stat.data_centers.push(d[0])
        end

        stat.data_centers = stat.data_centers.uniq

        asn_stats.push stat
      end

      Pipeline.new(200, p.payload.merge(asn_stats: asn_stats))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from prepare_asn_stats', e)
    end
  end

  def calculate_and_save_stats
    lambda do |p|
      p.payload[:asns].each do |asn, _|
        asn_stat = p.payload[:asn_stats]
                    .find { |stat| stat.traits_autonomous_system_number == asn }

        scores = p.payload[:scores].select do |score|
          score.data_center_key.in?(asn_stat.data_centers) && \
          score.validator.scorable?
        end

        active_stake = 0
        wage_sum = 0
        total_vote_distance_score = 0
        total_vote_distance_history = 0

        scores.each do |sc|
          active_stake += sc.active_stake.to_f
          wage_sum += (sc.vote_distance_score.to_i * sc.vote_distance_history.average).to_f
          total_vote_distance_history += sc.vote_distance_history.average
          total_vote_distance_score += sc.vote_distance_score.to_i
        end

        puts total_vote_distance_score

        asn_stat.population = scores.count
        asn_stat.vote_distance_moving_average = (wage_sum.to_f / total_vote_distance_score.to_f).to_f
        # puts "#{asn_stat.traits_autonomous_system_number} - #{asn_stat.network}: #{asn_stat.vote_distance_moving_average}"
        asn_stat.active_stake = active_stake
        asn_stat.calculated_at = DateTime.now

        asn_stat.save
      end

      Pipeline.new(200, p.payload)
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'Error from calculate_stats', e)
    end
  end

  def log_errors_to_file
    lambda do |p|
      unless p[:code] == 200
        asn_logger.error(p.errors.message)
        p.errors.backtrace.each do |line|
          asn_logger.error(line)
        end
        Rails.logger.error "PIPELINE ERROR CODE: #{p[:code]} MESSAGE: #{p[:message]} CLASS: #{p[:errors].class}"
      end
      p
    end
  end
end

private

def asn_logger
  @@asn_logger ||= Logger.new("#{Rails.root}/log/asn_logic.log")
end

def ips_sql
  "
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
end
