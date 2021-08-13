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

    @relation =
      VoteAccountHistory.where(
        network: network,
        batch_uuid: batch_uuid,
        vote_account_id: scorable_vote_accounts_ids
      )
  end

  def for_batch
    @for_batch ||= @relation
  end
end
