# frozen_string_literal: true

module ReportLogic
  include PipelineLogic

  def build_skipped_slot_percent
    lambda do |p|
      return p unless p[:code] == 200
      raise StandardError, 'Missing p[:payload][:network]' \
        unless p[:payload][:network]
      raise StandardError, 'Missing p[:payload][:batch_id]' \
        unless p[:payload][:batch_id]

      # Grab the block history for this batch
      block_history = ValidatorBlockHistory.where(
        batch_id: p[:payload][:batch_id]
      ).order('skipped_slot_percent asc')

      # Create a results array and insert the data
      result = []
      block_history.each do |history|
        result << {
          'validator_id' => history.validator.id,
          'account' => history.validator.account,
          'skipped_slots' => history.skipped_slots,
          'skipped_slot_percent' => history.skipped_slot_percent,
          'ping_time' => PingTime.where(to_account: history.validator.account)
                                 .order('id desc')
                                 .limit(20)
                                 .maximum('avg_ms')
        }
      end

      # Create the report
      Report.create(
        network: p[:payload][:network],
        batch_id: p[:payload][:batch_id],
        name: 'build_skipped_slot_percent',
        payload: result
      )

      Pipeline.new(200, p[:payload].merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'build_skipped_slot_percent', e)
    end
  end

  def build_skipped_after_percent
    lambda do |p|
      return p unless p[:code] == 200
      raise StandardError, 'Missing p[:payload][:network]' \
        unless p[:payload][:network]
      raise StandardError, 'Missing p[:payload][:batch_id]' \
        unless p[:payload][:batch_id]

      # Grab the block history for this batch
      block_history = ValidatorBlockHistory.where(
        batch_id: p[:payload][:batch_id]
      ).order('skipped_slots_after_percent asc')

      # Create a results array and insert the data
      result = []
      block_history.each do |history|
        result << {
          'validator_id' => history.validator.id,
          'account' => history.validator.account,
          'skipped_slots_after' => history.skipped_slots_after,
          'skipped_slots_after_percent' => history.skipped_slots_after_percent,
          'ping_time' => PingTime.where(to_account: history.validator.account)
                                 .order('id desc')
                                 .limit(20)
                                 .maximum('avg_ms')
        }
      end

      # Create the report
      Report.create(
        network: p[:payload][:network],
        batch_id: p[:payload][:batch_id],
        name: 'build_skipped_after_percent',
        payload: result
      )

      Pipeline.new(200, p[:payload].merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'build_skipped_slot_percent', e)
    end
  end

  def chart_home_page
    lambda do |p|
      return p unless p[:code] == 200
      raise StandardError, 'Missing p[:payload][:network]' \
        unless p[:payload][:network]
      raise StandardError, 'Missing p[:payload][:epoch]' \
        unless p[:payload][:epoch]

      # Grab the block history for the most recent bars
      # TODO: Add the :network to ValidatorBlockHistoryStat
      block_history = ValidatorBlockHistoryStat.where(
        # network: p[:payload][:network],
        epoch: p[:payload][:epoch]
      ).order('id desc').limit(100)

      # Create a results array and insert the data
      result = []
      block_history.each do |history|
        result << {
          # 'network' => history.network,
          'epoch' => history.epoch,
          'total_blocks_produced' => history.total_blocks_produced,
          'total_slots_skipped' => history.total_slots_skipped,
          'total_skipped_percent' => history.total_slots_skipped / history.total_blocks_produced.to_f
        }
      end

      # Create the report
      Report.create(
        network: p[:payload][:network],
        name: 'chart_home_page',
        payload: result
      )

      Pipeline.new(200, p[:payload].merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'chart_home_page', e)
    end
  end
end
