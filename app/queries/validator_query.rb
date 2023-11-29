# frozen_string_literal: true

class ValidatorQuery < ApplicationQuery
  include ValidatorsControllerHelper

  def initialize(watchlist_user: nil, api: false)
    @api = api
    @default_scope = if @api
                       default_api_scope
                     else
                       default_web_scope(watchlist_user)
                     end
  end

  def call(
      network: "mainnet",
      sort_order: "score",
      limit: 9999,
      page: 1,
      random_seed_val: 123,
      query_params: {
        admin_warning: nil,
        query: nil,
        jito: false,
        active_only: true
      }
    )
    scope = @default_scope.preload(:validator_score_v1_for_api)
    scope = filter_by_collaboration(scope, query_params[:jito])
    scope = filter_by_network(scope, network)
    scope = search_by(scope, query_params[:query]) if query_params[:query]
    scope = filter_by_admin_warning(scope, query_params[:admin_warning])
    scope = set_ordering(scope, sort_order, random_seed_val)
    scope = set_pagination(scope, page, limit)

    query_params[:active_only] ? scope.scorable : scope
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

  def set_ordering(scope, order, random_seed_val)
    sort_order = sort_order(order, random_seed_val)
    scope.order(sort_order)
  end

  def search_by(scope, query)
    ValidatorSearchQuery.new(scope).search(query)
  end

  def sort_order(order, random_seed_val)
    case order
    when "name"
      "validators.name asc"
    when "stake"
      "validator_score_v1s.network, validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc"
    else # Order by network + score + random by default
      [
        "validator_score_v1s.network",
        "validator_score_v1s.total_score desc",
        "RAND(#{random_seed_val})"
      ].join(", ")
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
