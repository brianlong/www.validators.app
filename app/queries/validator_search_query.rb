# frozen_string_literal: true

# QueryObject class created to extract query class methods from
# ValidatorsController.
# Usage:
# Set @relation by network in which query should run:
#   validator_search_query = ValidatorSearchQuery.new(relation)
# Call query method on scoped @relation
#   validator_search_query.search(query)

class ValidatorSearchQuery
  def initialize(relation = Validator.joins(:validator_score_v1))
    @relation = relation.joins(:validator_score_v1)
  end

  def search(query)
    # Return possible matches on Vote account in an Array
    # e.g. 888, 2331, 2267, 2670, 3184, 2241]
    # va_ids = if query.blank?
    #            []
    #          else
    #            VoteAccount.where('account LIKE ?', "#{query}%")
    #                       .pluck(:validator_id)
    #          end

    @relation.where(
      'name like :q or
      account like :q or
      validator_score_v1s.data_center_key like :q',
      q: "#{query}%"
    )
  end
end
