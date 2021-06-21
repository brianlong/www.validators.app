# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# VoteAccountHistory model.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   query = VoteAccountHistoryQuery.new(network, batch_uuid)
# Call query method on scoped @relation
#   query.average_skipped_vote_percent
#   query.median_skipped_vote_percent
class VoteAccountHistoryQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super
    scorable_vote_accounts_ids = Validator.scorable
                                          .joins(:vote_accounts)
                                          .pluck('vote_accounts.id')

    @relation ||=
      VoteAccountHistory.where(
        network: network,
        batch_uuid: batch_uuid,
        vote_account_id: scorable_vote_accounts_ids
      )
  end

  def average_skipped_vote_percent
    return @average_skipped_vote_percent if @average_skipped_vote_percent

    @average_skipped_vote_percent =
      vote_account_history_skipped.sum / vote_account_history_skipped.count
  end

  def median_skipped_vote_percent
    return @median_skipped_vote_percent if @median_skipped_vote_percent

    middle_index = vote_account_history_skipped.length / 2
    @median_skipped_vote_percent ||=
      vote_account_history_skipped.sort[middle_index]
  end

  def average_skipped_vote_percent_moving_average
    @average_skipped_vote_percent_moving_average ||=
      @relation.average(:skipped_vote_percent_moving_average)
  end

  def median_skipped_vote_percent_moving_average
    @median_skipped_vote_percent_moving_average ||=
      @relation.median(:skipped_vote_percent_moving_average)
  end

  def vote_account_history_skipped
    @vote_account_history_skipped ||=
      @relation.map(&:skipped_vote_percent)
  end

  def credits_current_max
    @credits_current_max ||=
      @relation.maximum(:credits_current).to_i
  end

  def slot_index_current
    @slot_index_current ||=
      @relation.maximum(:slot_index_current).to_i
  end

  def skipped_vote_percent_best
    if slot_index_current&.is_a?(Numeric) && slot_index_current.positive? && credits_current_max&.is_a?(Numeric)
      @skipped_vote_percent_best ||=
        (slot_index_current - credits_current_max) / slot_index_current.to_f
    else
      nil
    end
  end
end
