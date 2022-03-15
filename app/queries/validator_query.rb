class ValidatorQuery < ApplicationQuery
  include ValidatorsControllerHelper
  def initialize
    @default_scope = Validator.select(validator_fields, validator_score_v1_fields)
                              .includes(
                                :vote_accounts,
                                :most_recent_epoch_credits_by_account,
                                validator_score_v1: [:ip_for_api]
                              ).joins(:validator_score_v1)
  end

  def call(network: "mainnet", sort_order: "score", limit: 9999, page: 1, query: nil)
    scope = @default_scope
    scope = filter_by_network(scope, network)
    scope = search_by(scope, query)
    scope = set_ordering(scope, sort_order)
    scope = set_pagination(scope, page, limit)
  end

  private

  def filter_by_network(scope, network)
    scope.where(network: network)
  end

  def set_ordering(scope, order)
    sort_order = sort_order(order)
    scope.order(sort_order)
  end

  def search_by(scope, query)
    ValidatorSearchQuery.new(scope).search(query)
  end

  def sort_order(order)
    case order
    when "score"
      "validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc"
    when "name"
      "validators.name asc"
    when 'stake'
      "validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc"
    else
      "RAND()"
    end
  end

  def set_pagination(scope, page, limit)
    limit ||= 9999
    page ||= 1
    scope.page(page)
         .per(limit)
  end
end