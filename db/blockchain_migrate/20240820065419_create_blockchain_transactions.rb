class CreateBlockchainTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_mainnet_transactions do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :epoch

      t.references :block, foreign_key: { to_table: :blockchain_mainnet_blocks }, null: true

      t.timestamps
    end

    create_table :blockchain_testnet_transactions do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :epoch

      t.references :block, foreign_key: { to_table: :blockchain_testnet_blocks }, null: true

      t.timestamps
    end

    create_table :blockchain_pythnet_transactions do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :epoch
      
      t.references :block, foreign_key: { to_table: :blockchain_pythnet_blocks }, null: true

      t.timestamps
    end
  end
end
