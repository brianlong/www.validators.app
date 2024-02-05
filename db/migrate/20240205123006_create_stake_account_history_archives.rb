class CreateStakeAccountHistoryArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :stake_account_history_archives do |t|
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
      t.string :network
      t.integer :validator_id
      t.string :batch_uuid
      t.integer :epoch
      t.float :apy

      t.timestamps
    end
  end
end
