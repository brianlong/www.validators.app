# == Schema Information
#
# Table name: stake_account_histories
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
#  index_stake_account_histories_on_stake_pool_id             (stake_pool_id)
#  index_stake_account_histories_on_stake_pubkey_and_network  (stake_pubkey,network)
#  index_stake_account_histories_on_staker_and_network        (staker,network)
#  index_stake_account_histories_on_withdrawer_and_network    (withdrawer,network)
#

class StakeAccountHistory < ApplicationRecord
  extend Archivable

  belongs_to :stake_pool, optional: true
  belongs_to :validator, optional: true
end
