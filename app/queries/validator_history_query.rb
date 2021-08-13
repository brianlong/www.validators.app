# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorHistory model.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   query = ValidatorHistoryQuery.new(network, batch_uuid)
# Call query method on scoped @relation
#   query.for_batch
#   query.average_root_block
class ValidatorHistoryQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super

    @relation =
      ValidatorHistory.where(network: @network, batch_uuid: @batch_uuid)
  end

  # scopes ValidatorHistories by network and batch_uuid
  def for_batch
    @for_batch ||= @relation
  end
end
