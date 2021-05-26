class VoteAccountHistoryQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super

    @relation ||=
      VoteAccountHistory.where(network: network, batch_uuid: batch_uuid)
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
    @skipped_vote_percent_best ||=
      (slot_index_current - credits_current_max) / slot_index_current.to_f
  end
end
