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
  attr_reader :relation

  def initialize(network, batch_uuid)
    super

    @relation ||=
      ValidatorBlockHistory.where(network: network, batch_uuid: batch_uuid)
  end

  def for_batch
    @for_batch ||= @relation
  end
end
