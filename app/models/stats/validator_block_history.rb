module Stats
  class ValidatorBlockHistory < ApplicationStats
    def initialize(network, batch_uuid)
      super

      @relation = ValidatorBlockHistoryQuery.new(network, batch_uuid)
                                            .for_batch
    end

    def average_skipped_slot_percent
      @average_skipped_slot_percent ||=
        for_batch.average(:skipped_slot_percent_moving_average)
    end

    def scorable_average_skipped_slot_percent
      @scorable_average_skipped_slot_percent ||=
        for_batch.joins(:validator)
                 .where('validator.is_rpc': false, 'validator.is_active': true)
                 .average(:skipped_slot_percent_moving_average)
    end

    def median_skipped_slot_percent
      @median_skipped_slot_percent ||=
        for_batch.median(:skipped_slot_percent_moving_average)
    end

    def skipped_slot_percent_history_moving_average
      @skipped_slot_percent_history_moving_average ||=
        for_batch.joins(:validator)
                 .pluck(:skipped_slot_percent_moving_average, :account)
    end

    def skipped_slot_percent_history
      @skipped_slot_percent_history ||=
        for_batch.map(&:skipped_slot_percent)
    end

    def top_skipped_slot_percent
      @top_skipped_slot_percent ||=
        skipped_slot_percent_history_moving_average.sort.first(50)
    end

    def skipped_slot_stats(with_history: false)
      skipped_slot_stats = {
        min: skipped_slot_percent_history_moving_average.map(&:first).min,
        max: skipped_slot_percent_history_moving_average.map(&:first).max,
        median: median_skipped_slot_percent,
        average: average_skipped_slot_percent
      }

      return skipped_slot_stats unless with_history

      skipped_slot_stats.merge(history: skipped_slot_percent_history_moving_average)
    end

    private

    def for_batch
      @for_batch ||= @relation
    end
  end
end
