class ValidatorQuery < ApplicationQuery
  def initialize(network: "mainnet", sort_order: "score", limit: 9999, page: 1)
    @sort_order = case sort_order
    when 'score'
      'validator_score_v1s.total_score desc,  validator_score_v1s.active_stake desc'
    when 'name'
      'validators.name asc'
    when 'stake'
      'validator_score_v1s.active_stake desc, validator_score_v1s.total_score desc'
    else
      'RAND()'
    end

    @limit = limit
    @page = page
    @network = network

  end

  def call
    Validator.select(validator_fields, validator_score_v1_fields)
             .where(network: @network)
             .includes(:vote_accounts, :most_recent_epoch_credits_by_account, validator_score_v1: [:ip_for_api])
             .joins(:validator_score_v1)
             .order(@sort_order)
             .page(@page)
             .per(@limit)
  end

  def for_batch
    @for_batch ||= @relation
  end

  private

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