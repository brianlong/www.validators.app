# frozen_string_literal: true

module Stats

  # ValidatorBlockHistory set of stats scoped to certain batch.
  #
  # Usage: stats = Stats::ValidatorBlockHistory.new(network, batch_uuid)
  #            # network    - 'testnet', 'mainnet' or 'pythnet' atm
  #            # batch_uuid - batch in which look for
  #        stats.average_skipped_slot_percent
  #        stats.scorable_average_skipped_slot_percent
  #        stats.median_skipped_slot_percent
  #        stats.skipped_slot_percent_history
  #        ...
  class ValidatorBlockHistory < ApplicationStats
    def initialize(network, batch_uuid)
      super

      @relation = ::ValidatorBlockHistory.for_batch(network, batch_uuid)
    end

    def average_skipped_slot_percent
      @average_skipped_slot_percent ||=
        relation.average(:skipped_slot_percent_moving_average)
    end

    def scorable_average_skipped_slot_percent
      @scorable_average_skipped_slot_percent ||=
        relation.joins(:validator)
                .where('validator.is_rpc': false, 'validator.is_active': true)
                .average(:skipped_slot_percent_moving_average)
    end

    def median_skipped_slot_percent
      @median_skipped_slot_percent ||=
        relation.median(:skipped_slot_percent_moving_average)
    end

    def skipped_slot_percent_history_moving_average
      @skipped_slot_percent_history_moving_average ||=
        relation.joins(:validator)
                .pluck(:skipped_slot_percent_moving_average, :account)
    end

    def skipped_slot_percent_history
      @skipped_slot_percent_history ||=
        relation.map(&:skipped_slot_percent)
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

    def average_skipped_slots_after_percent
      relation.average(:skipped_slots_after_percent)
    end

    def median_skipped_slots_after_percent
      array_median(relation.pluck(:skipped_slots_after_percent).compact)
    end

    def data_for_validator_skipped_score
      relation.pluck(:validator_id, :skipped_slot_percent, :skipped_slot_percent_moving_average, :skipped_slot_after_percent_moving_average, :skipped_slots_after_percent)
    end
  end
end
