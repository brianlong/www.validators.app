#frozen_string_literal: true

# == Schema Information
#
# Table name: vote_account_stake_histories
#
#  id                              :bigint           not null, primary key
#  account_balance                 :bigint
#  active_stake                    :bigint
#  average_active_stake            :float(24)
#  credits_observed                :bigint
#  deactivating_stake              :bigint
#  delegated_stake                 :bigint
#  delegating_stake_accounts_count :integer
#  epoch                           :integer
#  network                         :string(191)
#  rent_exempt_reserve             :bigint
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  vote_account_id                 :bigint           not null
#
# Indexes
#
#  index_vote_account_stake_histories_on_vote_account     (network,epoch,vote_account_id) UNIQUE
#  index_vote_account_stake_histories_on_vote_account_id  (vote_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (vote_account_id => vote_accounts.id)
#
class VoteAccountStakeHistory < ApplicationRecord
  belongs_to :vote_account
end
