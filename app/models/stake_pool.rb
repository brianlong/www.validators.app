# == Schema Information
#
# Table name: stake_pools
#
#  id                            :bigint           not null, primary key
#  authority                     :string(191)
#  average_delinquent            :float(24)
#  average_lifetime              :integer
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
end
