class CreateVoteAccountStakeHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :vote_account_stake_histories do |t|
      t.references :vote_account, null: false, foreign_key: true
      t.integer :epoch
      t.bigint :delegated_stake
      t.bigint :account_balance
      t.bigint :active_stake
      t.bigint :credits_observed
      t.bigint :deactivating_stake
      t.bigint :rent_exempt_reserve
      t.integer :network
      t.integer :delegating_stake_accounts_count

      t.timestamps
      t.index %i[network epoch]
    end
  end
end
