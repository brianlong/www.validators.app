# frozen_string_literal: true

class ValidatorQuery < ApplicationQuery
  include ValidatorsControllerHelper

  RAND_SEED_VAL = 123

  def initialize(watchlist_user: nil, api: false)
    @api = api
    @default_scope = if @api
                       default_api_scope
                     else
                       default_web_scope(watchlist_user)
                     end
  end

  def call(network: "mainnet", sort_order: "score", limit: 9999, page: 1, query: nil, admin_warning: nil, jito: false)
    scope = @default_scope.preload(:validator_score_v1_for_api)
    scope = filter_by_collaboration(scope, jito)
    scope = filter_by_network(scope, network)
    scope = search_by(scope, query) if query
    scope = filter_by_admin_warning(scope, admin_warning)
    scope = set_ordering(scope, sort_order)
    scope = set_pagination(scope, page, limit)

    @api ? scope : scope.scorable
  end

  def call_single_validator(network: "mainnet", account:)
    scope = @default_scope
    scope = find_by_account(scope, network, account)
  end

  private

  def default_api_scope
    Validator.select(validator_fields, validator_score_v1_fields_for_api)
              .joins(:validator_score_v1_for_api)
              .includes(
                :vote_accounts_for_api,
                :most_recent_epoch_credits_by_account,
                validator_ip_active_for_api: [
                  data_center_host_for_api: [ :data_center_for_api ]
                ]
              )
  end

  def default_web_scope(watchlist_user)
    scope = Validator.select(validator_fields, validator_score_v1_fields_for_validators_index_web)
                     .joins(:validator_score_v1_for_web)
                     .includes(:validator_score_v1)

    if watchlist_user
      watched_validators_ids = User.find(watchlist_user).watched_validators.pluck(:validator_id)
      scope = scope.where(id: watched_validators_ids)
    end

    scope
  end

  def filter_by_collaboration(scope, jito)
    scope = jito ? scope.where(jito: true) : scope
  end

  def filter_by_network(scope, network)
    scope.where(network: network)
  end

  def filter_by_admin_warning(scope, admin_warning)
    return scope unless admin_warning.in? ["true", "false"] # ignore incorrect param
    admin_warning == "true" ? scope.where.not(admin_warning: nil) : scope.where(admin_warning: nil)
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
    when "name"
      "validators.name asc"
    when "stake"
      "validator_score_v1s.network, validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc"
    else # Order by score by default
      main_sort = "validator_score_v1s.network, validator_score_v1s.total_score desc"
      secondary_sort = if @api
                         "validator_score_v1s.active_stake desc"
                       else
                         "RAND(#{RAND_SEED_VAL + DateTime.current.hour})"
                       end

      [main_sort, secondary_sort].join(", ")
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
