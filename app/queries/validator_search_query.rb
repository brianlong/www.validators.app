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
    @relation = relation.joins(:validator_score_v1).left_joins(:data_center)
  end

  def search(query)
    vacs = VoteAccount.where('account LIKE ?', "#{query}%").pluck(:validator_id)
    @relation.where(
      'validators.name like :q or
      validators.account like :q or
      validator_score_v1s.software_version like :q or
      data_centers.data_center_key like :q or
      validators.id IN(:vacs)',
      q: "#{query}%",
      vacs: vacs
    )
  end
end
