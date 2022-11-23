# frozen_string_literal: true

module ReportLogic
  include PipelineLogic

  def build_skipped_slot_percent
    lambda do |p|
      return p unless p[:code] == 200
      raise StandardError, 'Missing p.payload[:network]' \
        unless p.payload[:network]
      raise StandardError, 'Missing p.payload[:batch_uuid]' \
        unless p.payload[:batch_uuid]

      # Grab the block history for this batch
      block_history = ValidatorBlockHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).order('skipped_slot_percent asc')

      # Create a results array and insert the data
      result = []
      block_history.find_each do |history|
        result << {
          'validator_id' => history.validator.id,
          'account' => history.validator.account,
          'skipped_slots' => history.skipped_slots,
          'skipped_slot_percent' => history.skipped_slot_percent
        }
      end

      raise 'No data' if result.empty?

      # Create the report
      Report.create(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        name: 'build_skipped_slot_percent',
        payload: result
      )

      Pipeline.new(200, p.payload.merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'build_skipped_slot_percent', e)
    end
  end

  def report_software_versions
    lambda do |p|
      batch_uuid = p.payload[:batch_uuid]
      network = p.payload[:network]

      return p unless p[:code] == 200
      raise StandardError, "Missing p.payload[:network]"    unless network
      raise StandardError, "Missing p.payload[:batch_uuid]" unless batch_uuid
      
      software_version_score_sql = %Q{
        SELECT vsv1.software_version, count(*) as count, SUM(vsv1.active_stake) as as_sum
        FROM validator_score_v1s AS vsv1
        JOIN validators as vals
        ON vsv1.validator_id = vals.id
        WHERE vsv1.network = :network
        AND vals.is_active = :is_active
        AND vals.is_rpc = :is_rpc
        GROUP BY vsv1.software_version;
      }.gsub(/\s+/, " ").strip

      conditions = {
        network: network,
        is_active: true,
        is_rpc: false
      }

      sanitized_sw_sql = ValidatorScoreV1.sanitize_sql([software_version_score_sql, conditions])

      software_versions_with_active_stake = ValidatorScoreV1.connection.execute(sanitized_sw_sql)

      total_active_stake = Validator.total_active_stake_for(network)

      # Create a results array and insert the data
      result = []
      software_versions_with_active_stake.each do |row|
        software_version = row[0] 
        count = row[1]  
        active_stake_sum = row[2]

        next if software_version.blank? || !Gem::Version.correct?(software_version) 

        stake_percent = if active_stake_sum # as_sum
                          ((active_stake_sum / total_active_stake.to_f) * 100).round(2)
                        else
                          nil
                        end

        result << { 
          software_version => { count: count, stake_percent: stake_percent } 
        }
      end
      
      raise 'No data' if result.empty?

      # Create the report
      Report.create(
        network: network,
        batch_uuid: batch_uuid,
        name: 'report_software_versions',
        payload: result
      )

      Pipeline.new(200, p.payload.merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'report_software_versions', e)
    end
  end
end
