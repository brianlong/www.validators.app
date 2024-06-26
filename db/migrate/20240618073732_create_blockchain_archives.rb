class CreateBlockchainArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_mainnet_slot_archives do |t|
      t.bigint :slot_number
      t.string :leader
      t.integer :epoch
      t.integer :status, default: 0

      t.timestamps
    end

    create_table :blockchain_testnet_slot_archives do |t|
      t.bigint :slot_number
      t.string :leader
      t.integer :epoch
      t.integer :status, default: 0

      t.timestamps
    end

    create_table :blockchain_pythnet_slot_archives do |t|
      t.bigint :slot_number
      t.string :leader
      t.integer :epoch
      t.integer :status, default: 0

      t.timestamps
    end

    create_table :blockchain_mainnet_block_archives do |t|
      t.bigint :slot_number
      t.string :blockhash
      t.integer :epoch
      t.integer :height
      t.bigint :parent_slot
      t.bigint :block_time

      t.timestamps
    end

    create_table :blockchain_testnet_block_archives do |t|
      t.bigint :slot_number
      t.string :blockhash
      t.integer :epoch
      t.integer :height
      t.bigint :parent_slot
      t.bigint :block_time

      t.timestamps
    end

    create_table :blockchain_pythnet_block_archives do |t|
      t.bigint :slot_number
      t.string :blockhash
      t.integer :epoch
      t.integer :height
      t.bigint :parent_slot
      t.bigint :block_time

      t.timestamps
    end

    create_table :blockchain_mainnet_transaction_archives do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :epoch
      t.bigint :block_id

      t.timestamps
    end

    create_table :blockchain_testnet_transaction_archives do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :epoch
      t.bigint :block_id

      t.timestamps
    end

    create_table :blockchain_pythnet_transaction_archives do |t|
      t.bigint :slot_number
      t.bigint :fee
      t.text :pre_balances
      t.text :post_balances
      t.string :account_key_1
      t.string :account_key_2
      t.string :account_key_3
      t.integer :epoch
      t.bigint :block_id

      t.timestamps
    end
  end
end
