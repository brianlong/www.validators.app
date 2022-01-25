# == Schema Information
#
# Table name: stake_pools
#
#  id                            :bigint           not null, primary key
#  authority                     :string(191)
#  average_delinquent            :float(24)
#  average_lifetime              :integer
#  average_score                 :float(24)
#  average_skipped_slots         :float(24)
#  average_uptime                :float(24)
#  average_validators_commission :float(24)
#  manager_fee                   :float(24)
#  name                          :string(191)
#  network                       :string(191)
#  ticker                        :string(191)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class StakePool < ApplicationRecord
  has_many :stake_accounts
  has_many :stake_account_histories

  def average_apy
    apy_data = stake_accounts.map do |sa| 
      if sa.apy && sa.active_stake > 0
        [sa.active_stake, sa.apy]
      else
        nil
      end
    end
    weighted_avg = apy_data.compact.inject(0) { |sum, n| sum + (n[0] * n[1]) }
    weighted_avg / stake_accounts.where.not(apy: nil, active_stake: nil).sum(:active_stake)
  end

  def validators_count
    stake_accounts.pluck(:validator_id).compact.uniq.count
  end
end
