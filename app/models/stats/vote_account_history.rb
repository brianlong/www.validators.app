# frozen_string_literal: true

module Stats

  # VoteAccountHistory set of stats scoped to certain batch.
  #
  # Usage: stats = Stats::VoteAccountHistory.new(network, batch_uuid)
  #            # network    - 'testnet', 'mainnet' or 'pythnet' atm
  #            # batch_uuid - batch in which look for
  #        stats.average_skipped_vote_percent
  #        stats.median_skipped_vote_percent
  #        stats.average_skipped_vote_percent_moving_average
  #        stats.median_skipped_vote_percent_moving_average
  #        ...
  class VoteAccountHistory < ApplicationStats
    def initialize(network, batch_uuid)
      super

      @relation = VoteAccountHistoryQuery.new(network, batch_uuid)
                                         .for_batch
    end

    def average_skipped_vote_percent
      return @average_skipped_vote_percent if @average_skipped_vote_percent
      return Float::NAN if vote_account_history_skipped.empty?

      @average_skipped_vote_percent =
        vote_account_history_skipped.sum / vote_account_history_skipped.size
    end

    def median_skipped_vote_percent
      return @median_skipped_vote_percent if @median_skipped_vote_percent

      middle_index = vote_account_history_skipped.length / 2
      @median_skipped_vote_percent ||= vote_account_history_skipped.sort[middle_index]
    end

    def average_skipped_vote_percent_moving_average
      @average_skipped_vote_percent_moving_average ||=
        relation.average(:skipped_vote_percent_moving_average)
    end

    def median_skipped_vote_percent_moving_average
      @median_skipped_vote_percent_moving_average ||=
        vote_account_history_skipped_moving_average.map(&:first).median
    end

    def vote_account_history_skipped_moving_average
      @vote_account_history_skipped_moving_average ||=
        relation.includes(vote_account: [:validator])
                .map { |vah| [vah.skipped_vote_percent_moving_average, vah.vote_account.validator.account] }
    end

    def vote_account_history_skipped
      @vote_account_history_skipped ||= relation.map(&:skipped_vote_percent)
    end

    def credits_current_max
      @credits_current_max ||= relation.maximum(:credits_current).to_i
    end

    def slot_index_current
      @slot_index_current ||= relation.maximum(:slot_index_current).to_i
    end

    def skipped_vote_percent_best
      if slot_index_current&.is_a?(Numeric) && slot_index_current.positive? && credits_current_max&.is_a?(Numeric)
        @skipped_vote_percent_best ||=
          (slot_index_current - credits_current_max) / slot_index_current.to_f
      else
        nil
      end
    end

    def top_skipped_vote_percent
      @top_skipped_vote_percent ||= vote_account_history_skipped_moving_average.sort.first(50)
    end

    def skipped_votes_stats(with_history: false)
      skipped_votes_stats = {
        min: vote_account_history_skipped.min,
        max: vote_account_history_skipped.max,
        median: median_skipped_vote_percent,
        average: average_skipped_vote_percent,
        best: skipped_vote_percent_best
      }

      return skipped_votes_stats unless with_history

      skipped_votes_stats.merge(history: vote_account_history_skipped)
    end

    def skipped_vote_moving_average_stats(with_history: false)
      skipped_vote_moving_average_stats = {
        min: vote_account_history_skipped_moving_average.map(&:first).min,
        max: vote_account_history_skipped_moving_average.map(&:first).max,
        median: median_skipped_vote_percent_moving_average,
        average: average_skipped_vote_percent_moving_average
      }
      return skipped_vote_moving_average_stats unless with_history

      skipped_vote_moving_average_stats.merge(
        history: vote_account_history_skipped_moving_average
      )
    end
  end
end
