# frozen_string_literal: true

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
    "name as pool_name"
  ].freeze

  VALIDATOR_FIELDS = [
    "name as validator_name",
    "account as validator_account"
  ].freeze

  VALIDATOR_SCORE_V1_FIELDS = ["active_stake as validator_active_stake"].freeze

  MINIMUM_STAKE = 1_000_000_000 # 1 sol

  def initialize(options)
    @network = options.fetch(:network, 'testnet')
    @sort_by = options.fetch(:sort_by, nil)
    @exclude_accounts_below_minimum_stake = options.fetch(:exclude_accounts_below_minimum_stake, nil)
    @filter_by = {
      account: options.fetch(:filter_account),
      staker: options.fetch(:filter_staker),
      withdrawer: options.fetch(:filter_withdrawer),
      validator: options.fetch(:filter_validator)
    }
  end

  def all_records
    stake_accounts = StakeAccount.left_outer_joins(:stake_pool)
                                 .left_outer_joins(validator: [:validator_score_v1])
                                 .select(query_fields)
                                 .where(
                                   network: @network,
                                 )
                                 .active

    stake_accounts = stake_accounts.filter_by_account(@filter_by[:account]) \
      unless @filter_by[:account].blank?

    stake_accounts = stake_accounts.filter_by_staker(@filter_by[:staker]) \
      unless @filter_by[:staker].blank?

    stake_accounts = stake_accounts.filter_by_withdrawer(@filter_by[:withdrawer]) \
      unless @filter_by[:withdrawer].blank?

    stake_accounts = stake_accounts.where("stake_accounts.active_stake > ?", MINIMUM_STAKE) \
      if @exclude_accounts_below_minimum_stake == "true"

    unless @filter_by[:validator].blank?
      selected_validators = ValidatorSearchQuery.new(
        Validator.where(network: @network)
      ).search(@filter_by[:validator]).pluck(:id)

      stake_accounts = stake_accounts.where(validator_id: selected_validators)
    end

    @sort_by.blank? ? stake_accounts : sorted(stake_accounts)
  end

  private

  def sorted(stake_accounts)
    case @sort_by
    when 'epoch_desc'
      stake_accounts.order(activation_epoch: :desc)
    when 'epoch_asc'
      stake_accounts.order(activation_epoch: :asc)
    when 'withdrawer_desc'
      stake_accounts.order(withdrawer: :desc)
    when 'withdrawer_asc'
      stake_accounts.order(withdrawer: :asc)
    when 'staker_desc'
      stake_accounts.order(staker: :desc)
    when 'staker_asc'
      stake_accounts.order(staker: :asc)
    when 'stake_desc'
      stake_accounts.order(delegated_stake: :desc)
    when 'stake_asc'
      stake_accounts.order(delegated_stake: :asc)
    else
      stake_accounts.order(created_at: :desc)
    end
  end

  def query_fields
    stake_account_fields = STAKE_ACCOUNT_FIELDS.map do |field|
      "stake_accounts.#{field}"
    end.join(", ")

    stake_pool_fields = STAKE_POOL_FIELDS.map do |field|
      "stake_pools.#{field}"
    end.join(", ")

    validator_fields = VALIDATOR_FIELDS.map do |field|
      "validators.#{field}"
    end.join(", ")

    validator_score_v1_fields = VALIDATOR_SCORE_V1_FIELDS.map do |field|
      "validator_score_v1s.#{field}"
    end.join(", ")

    [stake_account_fields, stake_pool_fields, validator_fields, validator_score_v1_fields].join(", ")
  end

end
