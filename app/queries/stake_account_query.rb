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

  attr_reader :payload

  def initialize(network: 'testnet', payload: nil)
    @network = network
    @payload = payload
  end

  def all_records
    stake_accounts = StakeAccount.left_outer_joins(:stake_pool)
                                 .left_outer_joins(:validator)
                                 .select(query_fields)
                                 .where(
                                   network: @network
                                 )

    StakeAccountQuery.new(network: @network, payload: stake_accounts)
  end

  def filter_by_account(account)
    p = account.blank? ? @payload : @payload.filter_by_account(account)
    StakeAccountQuery.new(network: @network, payload: p)
  end

  def filter_by_staker(staker)
    p = staker.blank? ? @payload : @payload.filter_by_staker(staker)
    StakeAccountQuery.new(network: @network, payload: p)
  end

  def filter_by_withdrawer(withdrawer)
    p = withdrawer.blank? ? @payload : @payload.filter_by_withdrawer(withdrawer)
    StakeAccountQuery.new(network: @network, payload: p)
  end

  def filter_by_validator(validator_query)
    unless validator_query.blank?
      selected_validators = ValidatorSearchQuery.new(
        Validator.where(network: @network)
      ).search(validator_query).pluck(:id)

      p = @payload.where(validator_id: selected_validators)
      return StakeAccountQuery.new(network: @network, payload: p)
    end
    StakeAccountQuery.new(network: @network, payload: @payload)
  end

  def sorted_by(sort_by)
    case sort_by
    when 'epoch_desc'
      p = @payload.order(activation_epoch: :desc)
    when 'epoch_asc'
      p = @payload.order(activation_epoch: :asc)
    when 'withdrawer_desc'
      p = @payload.order(withdrawer: :desc)
    when 'withdrawer_asc'
      p = @payload.order(withdrawer: :asc)
    when 'staker_desc'
      p = @payload.order(staker: :desc)
    when 'staker_asc'
      p = @payload.order(staker: :asc)
    when 'stake_desc'
      p = @payload.order(delegated_stake: :desc)
    when 'stake_asc'
      p = @payload.order(delegated_stake: :asc)
    else
      p = @payload.order(created_at: :desc)
    end
    StakeAccountQuery.new(network: @network, payload: p)
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
