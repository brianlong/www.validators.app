# == Schema Information
#
# Table name: stake_pools
#
#  id                            :bigint           not null, primary key
#  authority                     :string(191)
#  average_apy                   :float(24)
#  average_lifetime              :integer
#  average_score                 :float(24)
#  average_skipped_slots         :float(24)
#  average_uptime                :float(24)
#  average_validators_commission :float(24)
#  delinquent_count              :integer
#  deposit_fee                   :float(24)
#  gdi_score                     :float(24)
#  manager_fee                   :float(24)
#  name                          :string(191)
#  network                       :string(191)
#  next_manager_fee              :float(24)
#  next_withdrawal_fee           :float(24)
#  pool_address                  :string(191)
#  pool_token_supply             :bigint           unsigned
#  ticker                        :string(191)
#  total_lamports                :bigint           unsigned
#  withdrawal_fee                :float(24)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_stake_pools_on_network  (network)
#

class StakePool < ApplicationRecord

  API_FIELDS = %i[
    id
    authority
    average_apy
    average_lifetime
    average_score
    gdi_score
    average_skipped_slots
    average_uptime
    average_validators_commission
    manager_fee
    deposit_fee
    withdrawal_fee
    name
    network
    ticker
    validators_count
    total_stake
    average_stake
    delinquent_count
    pool_address
    total_lamports
    pool_token_supply
    exchange_rate
    next_manager_fee
    next_withdrawal_fee
  ].freeze

  has_many :stake_accounts, dependent: :destroy
  has_many :stake_account_histories, dependent: :destroy

  def validators_count
    stake_accounts.with_minimum_stake.pluck(:validator_id).compact.uniq.count
  end

  def total_stake
    stake_accounts.with_minimum_stake.pluck(:active_stake).compact.sum
  end

  def average_stake
    return 0 if validators_count == 0

    total_stake / validators_count
  end

  def exchange_rate
    return if total_lamports.blank? || pool_token_supply.to_i.zero?

    (total_lamports.to_f / pool_token_supply).round(9)
  end
end
