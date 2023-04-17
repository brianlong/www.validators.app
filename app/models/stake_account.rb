# frozen_string_literal: true

# == Schema Information
#
# Table name: stake_accounts
#
#  id                             :bigint           not null, primary key
#  account_balance                :bigint
#  activation_epoch               :integer
#  active_stake                   :bigint
#  apy                            :float(24)
#  batch_uuid                     :string(191)
#  credits_observed               :bigint
#  deactivating_stake             :bigint
#  deactivation_epoch             :integer
#  delegated_stake                :bigint
#  delegated_vote_account_address :string(191)
#  epoch                          :integer
#  network                        :string(191)
#  rent_exempt_reserve            :bigint
#  stake_pubkey                   :string(191)
#  stake_type                     :string(191)
#  staker                         :string(191)
#  withdrawer                     :string(191)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  stake_pool_id                  :integer
#  validator_id                   :integer
#
# Indexes
#
#  index_stake_accounts_on_stake_pool_id             (stake_pool_id)
#  index_stake_accounts_on_stake_pubkey_and_network  (stake_pubkey,network)
#  index_stake_accounts_on_staker_and_network        (staker,network)
#  index_stake_accounts_on_withdrawer_and_network    (withdrawer,network)
#

class StakeAccount < ApplicationRecord

  MINIMUM_STAKE = 1_000_000_000.freeze # 1 sol

  API_FIELDS = %i[
    id
    activation_epoch
    delegated_stake
    active_stake
    delegated_vote_account_address
    stake_pubkey
    staker
    withdrawer
    stake_pool_id
    network
    batch_uuid
  ].freeze

  API_VALIDATOR_FIELDS = %i[
    validator_name
    validator_account
    validator_active_stake
  ].freeze

  API_STAKE_POOL_FIELDS = %i[
    pool_name
  ].freeze

  belongs_to :stake_pool, optional: true
  belongs_to :validator, optional: true

  scope :filter_by_account, ->(account) { where('stake_pubkey LIKE ?', "#{account}%") }
  scope :filter_by_staker, ->(staker) { where('staker LIKE ?', "#{staker}%") }
  scope :filter_by_withdrawer, ->(withdrawer) { where('withdrawer LIKE ?', "#{withdrawer}%") }
  scope :active, ->() { where.not(active_stake: [0, nil]) }
  scope :with_minimum_stake, ->() { where("active_stake > ?", MINIMUM_STAKE) }

  def history_from_epoch(epoch)
    StakeAccountHistory.find_by(
      stake_pubkey: stake_pubkey,
      epoch: epoch
    )
  end

  def active?
    !active_stake.in?([0, nil])
  end

  def stake_pool_valid
    return unless stake_pool && self.active?
    return if active_stake < StakeAccountQuery::MINIMUM_STAKE

    stake_pool
  end
end
