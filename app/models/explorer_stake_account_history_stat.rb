# == Schema Information
#
# Table name: explorer_stake_account_history_stats
#
#  id                              :bigint           not null, primary key
#  account_balance                 :bigint
#  active_stake                    :bigint
#  credits_observed                :bigint
#  deactivating_stake              :bigint
#  delegated_stake                 :bigint
#  delegating_stake_accounts_count :integer
#  epoch                           :integer
#  network                         :string(191)
#  rent_exempt_reserve             :bigint
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
class ExplorerStakeAccountHistoryStat < ApplicationRecord
end
