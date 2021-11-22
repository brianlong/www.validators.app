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

  attr_reader :stake_accounts

  def initialize(network: 'testnet', stake_accounts: )
    @network = network
    @stake_accounts = stake_accounts
  end

  def all_records
    @stake_accounts = StakeAccount.left_outer_joins(:stake_pool)
                                 .left_outer_joins(:validator)
                                 .select(query_fields)
                                 .where(
                                   network: @network
                                 )
  end

  def filter_by_account(account)
    @stake_accounts = account.blank? ? @stake_accounts : @stake_accounts.filter_by_account(account)
  end

  def filter_by_staker(staker)
    @stake_accounts = staker.blank? ? @stake_accounts : @stake_accounts.filter_by_staker(staker)
  end

  def filter_by_withdrawer(withdrawer)
    @stake_accounts = withdrawer.blank? ? @stake_accounts : @stake_accounts.filter_by_withdrawer(withdrawer)
  end

  def filter_by_validator(validator_query)
    unless validator_query.blank?
      selected_validators = ValidatorSearchQuery.new(
        Validator.where(network: @network)
      ).search(validator_query).pluck(:id)

      @stake_accounts = @stake_accounts.where(validator_id: selected_validators)
    end
    @stake_accounts
  end

  def sorted_by(sort_by)
    case sort_by
    when 'epoch_desc'
      p = @stake_accounts.order(activation_epoch: :desc)
    when 'epoch_asc'
      p = @stake_accounts.order(activation_epoch: :asc)
    when 'withdrawer_desc'
      p = @stake_accounts.order(withdrawer: :desc)
    when 'withdrawer_asc'
      p = @stake_accounts.order(withdrawer: :asc)
    when 'staker_desc'
      p = @stake_accounts.order(staker: :desc)
    when 'staker_asc'
      p = @stake_accounts.order(staker: :asc)
    when 'stake_desc'
      p = @stake_accounts.order(delegated_stake: :desc)
    when 'stake_asc'
      p = @stake_accounts.order(delegated_stake: :asc)
    else
      p = @stake_accounts.order(created_at: :desc)
    end
    @stake_accounts
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
