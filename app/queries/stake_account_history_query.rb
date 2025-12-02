# frozen_string_literal: true

class StakeAccountHistoryQuery
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

  def initialize(options)
    @network = options.fetch(:network, 'testnet') || 'testnet'
    @epoch = options.fetch(:epoch, nil)

    @filter_by = {
      account: options.fetch(:filter_account),
      staker: options.fetch(:filter_staker),
      withdrawer: options.fetch(:filter_withdrawer),
      pool: options.fetch(:filter_pool)
    }
  end

  def all_records
    stake_accounts = StakeAccountHistory.left_outer_joins(:stake_pool)
                                        .left_outer_joins(validator: [:validator_score_v1])
                                        .select(query_fields)
                                        .where(
                                          epoch: @epoch,
                                          network: @network,
                                        )

    stake_accounts = stake_accounts.filter_by_account(@filter_by[:account]) unless @filter_by[:account].blank?

    stake_accounts = stake_accounts.filter_by_staker(@filter_by[:staker]) unless @filter_by[:staker].blank?

    stake_accounts = stake_accounts.filter_by_withdrawer(@filter_by[:withdrawer]) unless @filter_by[:withdrawer].blank?

    if @filter_by[:pool].present?
      pool_id = StakePool.where(network: @network).where('LOWER(name) = ?', @filter_by[:pool])&.last&.id
      stake_accounts = stake_accounts.filter_by_pool(pool_id)
    end

    stake_accounts
  end

  private

  def query_fields
    stake_account_fields = STAKE_ACCOUNT_FIELDS.map do |field|
      "stake_account_histories.#{field}"
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
