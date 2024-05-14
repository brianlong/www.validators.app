class CreateBlockchainTransactionArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_transaction_archives do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :block_id
      
      t.timestamps
    end
  end
end
