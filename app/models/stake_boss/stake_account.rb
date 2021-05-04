# frozen_string_literal: true

# == Schema Information
#
# Table name: stake_boss_stake_accounts
#
#  id                             :bigint           not null, primary key
#  account_balance                :bigint           unsigned
#  activating_stake               :bigint           unsigned
#  activation_epoch               :integer
#  active_stake                   :bigint           unsigned
#  address                        :string(255)
#  batch_uuid                     :string(255)
#  credits_observed               :bigint           unsigned
#  deactivation_epoch             :integer
#  delegated_stake                :bigint           unsigned
#  delegated_vote_account_address :string(255)
#  epoch                          :integer
#  epoch_rewards                  :bigint           unsigned
#  lockup_custodian               :string(255)
#  lockup_timestamp               :bigint           unsigned
#  network                        :string(255)
#  primary_account                :boolean          default(FALSE)
#  rent_exempt_reserve            :bigint           unsigned
#  split_n_ways                   :integer
#  split_on                       :datetime
#  stake_authority                :string(255)
#  stake_type                     :string(255)
#  withdraw_authority             :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  user_id                        :bigint           unsigned
#
# Indexes
#
#  stake_boss_stake_accounts_batch_uuid_primary_account  (batch_uuid,primary_account)
#  stake_boss_stake_accounts_network_address             (network,address) UNIQUE
#  stake_boss_stake_accounts_user_id                     (user_id)
#
module StakeBoss
  # StakeBoss::StakeAccount represents the StakeAccounts that are managed by
  # the Stake Boss
  #
  # * Raises:
  #   - Exception => When the Exception is raised.
  # * Examples:
  #     Indent example code two spaces for best formatting after 'rake doc:app'
  class StakeAccount < ApplicationRecord
    audited

    # Just an alias for primary_account
    def primary_account?
      primary_account
    end
  end
end
