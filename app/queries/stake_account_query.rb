class StakeAccountQuery
  STAKE_ACCOUNT_FIELDS = %w[
    created_at
    activation_epoch
    active_stake
    delegated_stake
    network
    delegated_vote_account_address
    id
    stake_pubkey
    batch_uuid
    stake_pool_id
    staker
    withdrawer
  ].freeze

  STAKE_POOL_FIELDS = [
    'name as pool_name'
  ].freeze

  VALIDATOR_FIELDS = [
    'name as validator_name',
    'account as validator_account'
  ].freeze

  def initialize(network: 'testnet', relation: StakeAccount)
    @network = network
    @relation = relation
  end

  def call(
    account: nil,
    staker: nil,
    withdrawer: nil,
    sort: nil,
    validator_query: nil
  )

    relation = all_records
    relation = filter_by_account(relation, account) if account
    relation = filter_by_staker(relation, staker) if staker
    relation = filter_by_withdrawer(relation, withdrawer) if withdrawer
    relation = sort(relation, sort) if sort
    relation = filter_by_validator_ids(relation, validator_query: validator_query) if validator_query.present?

    relation
  end

  def all_records
    @relation.left_outer_joins(:stake_pool)
             .left_outer_joins(:validator)
             .select(query_fields)
             .where(network: @network)
  end

  def filter_by_account(relation, account)
    relation.filter_by_account(account)
  end

  def filter_by_staker(relation, staker)
    relation.filter_by_staker(staker)
  end

  def filter_by_withdrawer(relation, withdrawer)
    relation.filter_by_withdrawer(withdrawer)
  end

  def filter_by_validator_ids(relation, validator_query: nil)
    validator_ids = ValidatorSearchQuery.new(
      Validator.where(network: @network)
    ).search(validator_query).pluck(:id)

    relation.where(validator_id: validator_ids)
  end

  def sort(relation, sort_by)
    case sort_by
    when 'epoch_desc'
      relation.order(activation_epoch: :desc)
    when 'epoch_asc'
      relation.order(activation_epoch: :asc)
    when 'withdrawer_desc'
      relation.order(withdrawer: :desc)
    when 'withdrawer_asc'
      relation.order(withdrawer: :asc)
    when 'staker_desc'
      relation.order(staker: :desc)
    when 'staker_asc'
      relation.order(staker: :asc)
    when 'stake_desc'
      relation.order(delegated_stake: :desc)
    when 'stake_asc'
      relation.order(delegated_stake: :asc)
    else
      relation.order(created_at: :desc)
    end

    relation
  end

  private

  def query_fields
    stake_account_fields = STAKE_ACCOUNT_FIELDS.map do |field|
      "stake_accounts.#{field}"
    end.join(', ')

    stake_pool_fields = STAKE_POOL_FIELDS.map do |field|
      "stake_pools.#{field}"
    end.join(', ')

    validator_fields = VALIDATOR_FIELDS.map do |field|
      "validators.#{field}"
    end.join(', ')

    [stake_account_fields, stake_pool_fields, validator_fields].join(', ')
  end
end
