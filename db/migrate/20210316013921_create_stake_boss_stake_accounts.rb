class CreateStakeBossStakeAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :stake_boss_stake_accounts do |t|
      t.bigint :user_id, unsigned: true
      t.string :batch_uuid
      t.string :network
      t.string :address
      t.bigint :account_balance, unsigned: true
      t.bigint :activating_stake, unsigned: true
      t.integer :activation_epoch
      t.bigint :active_stake, unsigned: true
      t.bigint :credits_observed, unsigned: true
      t.integer :deactivation_epoch
      t.bigint :delegated_stake, unsigned: true
      t.string :delegated_vote_account_address
      t.integer :epoch
      t.bigint :epoch_rewards, unsigned: true
      t.string :lockup_custodian
      t.bigint :lockup_timestamp, unsigned: true
      t.bigint :rent_exempt_reserve, unsigned: true
      t.string :stake_authority
      t.string :stake_type
      t.string :withdraw_authority
      t.integer :split_n_ways
      t.boolean :primary_account, default: false
      t.datetime :split_on
      t.timestamps
    end
    add_index :stake_boss_stake_accounts,
              %i[network address],
              unique: true,
              name: 'stake_boss_stake_accounts_network_address'
    add_index :stake_boss_stake_accounts,
              :user_id,
              name: 'stake_boss_stake_accounts_user_id'
    add_index :stake_boss_stake_accounts,
              %i[batch_uuid primary_account],
              name: 'stake_boss_stake_accounts_batch_uuid_primary_account'
  end
end
