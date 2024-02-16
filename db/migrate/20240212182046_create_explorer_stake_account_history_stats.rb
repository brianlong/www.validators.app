class CreateExplorerStakeAccountHistoryStats < ActiveRecord::Migration[6.1]
  def change
    create_table :explorer_stake_account_history_stats do |t|
      t.integer :epoch
      t.bigint :delegated_stake
      t.bigint :account_balance
      t.bigint :active_stake
      t.float :average_active_stake
      t.bigint :credits_observed
      t.bigint :deactivating_stake
      t.bigint :rent_exempt_reserve
      t.string :network
      t.integer :delegating_stake_accounts_count

      t.timestamps

      t.index %i[epoch network], unique: true
    end
  end
end
