# == Schema Information
#
# Table name: stake_pools
#
#  id                            :bigint           not null, primary key
#  authority                     :string(191)
#  average_apy                   :float(24)
#  average_delinquent            :float(24)
#  average_lifetime              :integer
#  average_score                 :float(24)
#  average_skipped_slots         :float(24)
#  average_uptime                :float(24)
#  average_validators_commission :float(24)
#  deposit_fee                   :float(24)
#  manager_fee                   :float(24)
#  name                          :string(191)
#  network                       :string(191)
#  ticker                        :string(191)
#  withdrawal_fee                :float(24)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
# Indexes
#
#  index_stake_pools_on_network  (network)
#

class StakePool < ApplicationRecord
  has_many :stake_accounts
  has_many :stake_account_histories

  def validators_count
    stake_accounts.pluck(:validator_id).compact.uniq.count
  end

  def total_stake
    stake_accounts&.pluck(:active_stake).compact.sum
  end

  def average_stake
    return 0 if validators_count == 0
    total_stake / validators_count
  end
end
