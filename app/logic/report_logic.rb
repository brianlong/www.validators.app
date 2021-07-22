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
      block_history.each do |history|
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

  # Sample payload
  # [{"epoch":61,"end_slot":20988266,"total_blocks_produced":145785,"total_slots_skipped":14226,"total_skipped_percent":0.09758205576705423},...]
  def chart_home_page
    lambda do |p|
      return p unless p[:code] == 200
      raise StandardError, 'Missing p.payload[:network]' \
        unless p.payload[:network]
      raise StandardError, 'Missing p.payload[:epoch]' \
        unless p.payload[:epoch]

      # Grab the block history for the most recent bars
      # TODO: Add the :network to ValidatorBlockHistoryStat
      block_history = ValidatorBlockHistoryStat.where(
        network: p.payload[:network],
        epoch: p.payload[:epoch]
      ).order('id desc').limit(500)

      # Create a results array and insert the data
      result = []
      block_history.each do |history|
        # Calculate the median skipped slots for this batch_uuid
        vbh = ValidatorBlockHistory.where(
          network: p.payload[:network],
          batch_uuid: history.batch_uuid
        ).all

        array_sorted = vbh.map(&:skipped_slot_percent).sort
        array_length = array_sorted.length
        array_center = array_length / 2
        median_skipped = array_length.even? ? (array_sorted[array_center] + array_sorted[array_center + 1]) / 2.0 : array_sorted[array_center]

        result << {
          # 'network' => history.network,
          'epoch' => history.epoch,
          'end_slot' => history.end_slot,
          'total_slots' => history.total_blocks_produced,
          'total_slots_skipped' => history.total_slots_skipped,
          'total_skipped_percent' => history.total_slots_skipped / history.total_slots.to_f,
          'median_skipped_percent' => median_skipped.to_f
        }
      end

      raise 'No data' if result.empty?

      # Create the report
      Report.create(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        name: 'chart_home_page',
        payload: result
      )

      Pipeline.new(200, p.payload.merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'chart_home_page', e)
    end
  end

  # Create a report to show tower height.
  def report_tower_height
    lambda do |p|
      return p unless p.code == 200
      raise StandardError, 'Missing p.payload[:network]' \
        unless p.payload[:network]
      raise StandardError, 'Missing p.payload[:batch_uuid]' \
        unless p.payload[:batch_uuid]

      highest_block = ValidatorHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).maximum(:root_block)

      # Grab the block history for this batch
      validators = ValidatorHistory.where(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid]
      ).order('root_block desc, active_stake desc').all

      # Create a results array and insert the data
      result = []
      validators.each do |validator|
        validator_root_block = validator.root_block || 0
        blocks_behind_leader = highest_block - validator_root_block
        result << {
          'epoch' => p.payload[:epoch],
          'account' => validator.account,
          'root_block' => validator.root_block,
          'blocks_behind_leader' => blocks_behind_leader,
          'active_stake' => validator.active_stake,
          'delinquent' => validator.delinquent
        }
      end

      raise 'No data' if result.empty?

      # Create the report
      Report.create(
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        name: 'report_tower_height',
        payload: result
      )

      Pipeline.new(200, p.payload.merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'report_tower_height', e)
    end
  end

  def report_software_versions
    lambda do |p|
      return p unless p[:code] == 200
      raise StandardError, 'Missing p.payload[:network]' \
        unless p.payload[:network]
      raise StandardError, 'Missing p.payload[:batch_uuid]' \
        unless p.payload[:batch_uuid]
      
      batch_created_at = Batch.find_by(uuid: p.payload[:batch_uuid])&.created_at

      sql = "SELECT software_version, count(*) as count, SUM(active_stake) as as_sum
             FROM validator_score_v1s 
             WHERE network = '#{p.payload[:network]}'
             AND updated_at > '#{batch_created_at}'
             GROUP BY software_version;"
      # Grab the vote history for this batch
      software_versions_with_active_stake = ValidatorScoreV1.connection.execute(sql)

      total_active_stake = Validator.total_active_stake_for(p.payload[:network])

      # Create a results array and insert the data
      result = []
      software_versions_with_active_stake.each do |row|
        software_version = row[0] 
        count = row[1]  
        active_stake_sum = row[2]

        next if software_version.blank?

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
        network: p.payload[:network],
        batch_uuid: p.payload[:batch_uuid],
        name: 'report_software_versions',
        payload: result
      )

      Pipeline.new(200, p.payload.merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p.payload, 'report_software_versions', e)
    end
  end
end
