class CreateStakeAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :stake_accounts do |t|
      t.bigint :account_balance
      t.integer :activation_epoch
      t.bigint :active_stake
      t.bigint :credits_observed
      t.bigint :deactivating_stake
      t.integer :deactivation_epoch
      t.bigint :delegated_stake
      t.string :delegated_vote_account_address
      t.bigint :rent_exempt_reserve
      t.string :stake_pubkey
      t.string :stake_type
      t.string :staker
      t.string :withdrawer
      t.integer :stake_pool_id

      t.timestamps

      t.index :stake_pubkey
      t.index :staker
      t.index :withdrawer
      t.index :stake_pool_id
    end
  end
end
