# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorScoreV1 model.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   query = ValidatorScoreQuery.new(network, batch_uuid)
# Call query method on scoped @relation
#   query.for_batch
class ValidatorScoreQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super

    @validators = ValidatorHistory.for_batch(network, batch_uuid)
                                  .map(&:validator)
                                  .compact

    @relation = ValidatorScoreV1.where(validator_id: @validators.map(&:id))
  end

  def for_batch
    @for_batch ||= @relation
  end
end
