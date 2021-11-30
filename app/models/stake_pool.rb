# == Schema Information
#
# Table name: stake_pools
#
#  id          :bigint           not null, primary key
#  authority   :string(191)
#  manager_fee :float(24)
#  name        :string(191)
#  network     :string(191)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class StakePool < ApplicationRecord
  has_many :stake_accounts
  has_many :stake_account_histories
end
