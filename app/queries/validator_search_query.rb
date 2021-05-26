# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorsController.
# Usage:
# Set @relation by network and batch_uuid in which query should run:
#   validator_search_query = ValidatorSearchQuery.new(relation)
# Call query method on scoped @relation
#   validator_search_query.search(query)

class ValidatorSearchQuery
  def initialize(relation = Validator.joins(:validator_score_v1))
    @relation = relation.joins(:validator_score_v1)
  end

  def search(query)
    @relation.where(
      'name like :q or account like :q or validator_score_v1s.data_center_key like :q',
      q: "#{query}%"
    )
  end
end
