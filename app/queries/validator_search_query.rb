# frozen_string_literal: true

# TODO: Documentation
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
