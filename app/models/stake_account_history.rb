# == Schema Information
#
# Table name: stake_account_histories
#
#  id                             :bigint           not null, primary key
#  account_balance                :bigint
#  activation_epoch               :integer
#  active_stake                   :bigint
#  batch_uuid                     :string(191)
#  credits_observed               :bigint
#  deactivating_stake             :bigint
#  deactivation_epoch             :integer
#  delegated_stake                :bigint
#  delegated_vote_account_address :string(191)
#  rent_exempt_reserve            :bigint
#  stake_pubkey                   :string(191)
#  stake_type                     :string(191)
#  staker                         :string(191)
#  withdrawer                     :string(191)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  stake_pool_id                  :integer
#
class StakeAccountHistory < ApplicationRecord
end
