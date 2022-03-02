# frozen_string_literal: true

module AsnLogic
  include PipelineLogic

  def gather_asns
    lambda do |p|
      data_centers = DataCenter.connection.execute(
        ActiveRecord::Base.send(:sanitize_sql, [ips_sql, p.payload[:network]])
      )
      sorted_by_asn = data_centers.group_by { |dc| dc[1] }

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
            score.validator.scorable? && \
            !score.validator.private_validator? && \
            score.total_score.present? && \
            score.active_stake.present?
        end

        score_sum = 0
        active_stake = 0
        
        scores.each do |sc|
          score_sum += sc.total_score
          active_stake += sc.active_stake
        end

        asn_stat.population = scores.count
        if asn_stat.population&.positive?
          asn_stat.average_score = \
            (score_sum.to_f / asn_stat.population)
        else
          asn_stat.average_score = 0
        end
        asn_stat.active_stake = active_stake

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
  log_path = File.join(Rails.root, 'log', Rails.env)
  log_file_name = 'asn_logic.log'
  log_file_path = File.join(log_path, log_file_name)

  FileUtils.mkdir_p(log_path)

  @asn_logger ||= Logger.new(log_file_path)
end

def ips_sql
  "
    SELECT data_centers.data_center_key,
           data_centers.traits_autonomous_system_number,
           data_centers.traits_autonomous_system_organization,
           data_centers.country_iso_code,
           IF(ISNULL(city_name), location_time_zone, city_name) as location
    FROM data_centers
    JOIN validator_score_v1s score
    WHERE score.network = ?
    AND score.active_stake > 0
  "
end
