# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorBlockHistory model.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   query = ValidatorBlockHistoryQuery.new(network, batch_uuid)
# Call query method on scoped @relation
#   query.average_skipped_slot_percent
#   query.median_skipped_slot_percent
class ValidatorBlockHistoryQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super

    @relation ||=
      ValidatorBlockHistory.where(network: network, batch_uuid: batch_uuid)
  end

  def average_skipped_slot_percent
    @average_skipped_slot_percent ||=
      @relation.average(:skipped_slot_percent_moving_average)
  end

  def median_skipped_slot_percent
    @median_skipped_slot_percent ||=
      @relation.median(:skipped_slot_percent_moving_average)
  end

  def skipped_slot_percent_history_moving_average
    @skipped_slot_percent_history_moving_average ||=
      @relation.pluck(:skipped_slot_percent_moving_average)
  end

  def skipped_slot_percent_history
    @skipped_slot_percent_history ||=
      @relation.map(&:skipped_slot_percent)
  end

  def skipped_slot_stats
    {
      min: skipped_slot_percent_history_moving_average.min,
      max: skipped_slot_percent_history_moving_average.max,
      median: median_skipped_slot_percent,
      average: average_skipped_slot_percent,
      history: skipped_slot_percent_history_moving_average
    }
  end
end
