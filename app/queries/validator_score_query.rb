# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorScoreV1 model.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   query = ValidatorScoreQuery.new(network, batch_uuid)
# Call query method on scoped @relation
#   query.for_batch
#   query.
class ValidatorScoreQuery < ApplicationQuery
  def initialize(network, batch_uuid)
    super

    @relation =
      ValidatorScoreV1.joins(<<-SQL)
                      LEFT JOIN (SELECT #{Validator.table_name}.id
                        ON validators.id = validator_id
                      SQL
                      .where(<<-SQL)
                        validators.network = '#{network}'
                        and validators.batch_uuid = '#{batch_uuid}'
                      SQL
  end

  def for_batch
    @for_batch = @relation
  end
end
