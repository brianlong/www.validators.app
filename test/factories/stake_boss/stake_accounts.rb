# == Schema Information
#
# Table name: stake_boss_stake_accounts
#
#  id                             :bigint           not null, primary key
#  user_id                        :bigint           unsigned
#  batch_uuid                     :string(255)
#  network                        :string(255)
#  address                        :string(255)
#  account_balance                :bigint           unsigned
#  activating_stake               :bigint           unsigned
#  activation_epoch               :integer
#  active_stake                   :bigint           unsigned
#  credits_observed               :bigint           unsigned
#  deactivation_epoch             :integer
#  delegated_stake                :bigint           unsigned
#  delegated_vote_account_address :string(255)
#  epoch                          :integer
#  epoch_rewards                  :bigint           unsigned
#  lockup_custodian               :string(255)
#  lockup_timestamp               :bigint           unsigned
#  rent_exempt_reserve            :bigint           unsigned
#  stake_authority                :string(255)
#  stake_type                     :string(255)
#  withdraw_authority             :string(255)
#  split_n_ways                   :integer
#  primary_account                :boolean          default(FALSE)
#  split_on                       :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
FactoryBot.define do
  factory :stake_boss_stake_account, class: 'StakeBoss::StakeAccount' do
    
  end
end
