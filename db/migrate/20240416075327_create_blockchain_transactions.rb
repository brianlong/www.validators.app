class CreateBlockchainTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_transactions do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.references :block, null: false, foreign_key: { to_table: :blockchain_blocks }
      t.timestamps
    end
  end
end
