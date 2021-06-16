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

  def for_batch
    @for_batch ||= @relation
  end

  def average_skipped_slot_percent
    @average_skipped_slot_percent ||=
      for_batch.average(:skipped_slot_percent_moving_average)
  end

  def median_skipped_slot_percent
    @median_skipped_slot_percent ||=
      for_batch.median(:skipped_slot_percent_moving_average)
  end

  def skipped_slot_percent_history_moving_average
    @skipped_slot_percent_history_moving_average ||=
      for_batch.pluck(:skipped_slot_percent_moving_average)
  end

  def skipped_slot_percent_history
    @skipped_slot_percent_history ||=
      for_batch.map(&:skipped_slot_percent)
  end

  def top_skipped_slot_percent
    @top_skipped_slot_percent ||=
      skipped_slot_percent_history_moving_average.sort.reverse
  end

  def skipped_slot_stats(with_history: false)
    skipped_slot_stats = {
      min: skipped_slot_percent_history_moving_average.min,
      max: skipped_slot_percent_history_moving_average.max,
      median: median_skipped_slot_percent,
      average: average_skipped_slot_percent
    }

    return skipped_slot_stats unless with_history

    skipped_slot_stats.merge(history: skipped_slot_percent_history_moving_average)
  end
end
