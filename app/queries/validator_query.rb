class ValidatorQuery < ApplicationQuery
  def initialize
    @default_scope = Validator.select(validator_fields, validator_score_v1_fields)
                              .includes(
                                :vote_accounts,
                                :most_recent_epoch_credits_by_account,
                                validator_score_v1: [:ip_for_api]
                              ).eager_load(:validator_score_v1)
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
    when 'score'
      'validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc'
    when 'name'
      'validators.name asc'
    when 'stake'
      'validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc'
    else
      'RAND()'
    end
  end

  def set_pagination(scope, page, limit)
    scope.page(page)
         .per(limit)
  end

  def validator_fields
    [
      'account',
      'created_at',
      'details',
      'id',
      'keybase_id',
      'name',
      'network',
      'updated_at',
      'www_url',
      'avatar_url',
      'admin_warning'
    ].map { |e| "validators.#{e}" }
  end

  def validator_score_v1_fields
    [
      'active_stake',
      'commission',
      'delinquent',
      'data_center_concentration_score',
      'data_center_key',
      'data_center_host',
      'published_information_score',
      'root_distance_score',
      'security_report_score',
      'skipped_slot_score',
      'software_version',
      'software_version_score',
      'stake_concentration_score',
      'total_score',
      'validator_id',
      'vote_distance_score'
    ].map { |e| "validator_score_v1s.#{e}" }
  end
end