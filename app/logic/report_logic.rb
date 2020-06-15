# frozen_string_literal: true

module ReportLogic
  include PipelineLogic

  def build_top_skipped_slot_percent
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
        name: 'build_top_skipped_slot_percent',
        payload: result
      )

      Pipeline.new(200, p[:payload].merge(result: result))
    rescue StandardError => e
      Pipeline.new(500, p[:payload], 'build_top_skipped_slot_percent', e)
    end
  end
end
