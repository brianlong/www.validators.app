# frozen_string_literal: true

class ValidatorQuery < ApplicationQuery
  include ValidatorsControllerHelper
  def initialize(user_id: nil)
    @default_scope = if user_id && user = User.find(user_id)
                       user.watched_validators.select(validator_fields, validator_score_v1_fields)
                           .joins(:validator_score_v1_for_api)
                           .includes(
                             :vote_accounts_for_api,
                             :most_recent_epoch_credits_by_account,
                             validator_ip_active_for_api: [data_center_host_for_api: [:data_center_for_api]]
                           )
                     else
                       Validator.select(validator_fields, validator_score_v1_fields)
                                .joins(:validator_score_v1_for_api)
                                .includes(
                                  :vote_accounts_for_api,
                                  :most_recent_epoch_credits_by_account,
                                  validator_ip_active_for_api: [data_center_host_for_api: [:data_center_for_api]]
                                )
                     end                       
  end

  def call(network: "mainnet", sort_order: "score", limit: 9999, page: 1, query: nil)
    scope = @default_scope.preload(:validator_score_v1_for_api)
    scope = filter_by_network(scope, network)
    scope = search_by(scope, query)
    scope = set_ordering(scope, sort_order)
    scope = set_pagination(scope, page, limit)
    scope.scorable
  end

  def call_single_validator(network: "mainnet", account:)
    scope = @default_scope
    scope = find_by_account(scope, network, account)
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
    when "stake"
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

  def find_by_account(scope, network, account)
    scope.find_by(network: network, account: account)
  end
end