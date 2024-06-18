class SplitBlockchainBlockToSeparateNetworks < ActiveRecord::Migration[6.1]
  def change
    remove_reference :blockchain_transactions, :block, null: false, foreign_key: { to_table: :blockchain_blocks }
    drop_table :blockchain_blocks

    create_table :blockchain_mainnet_blocks do |t|
      t.bigint :slot_number
      t.string :blockhash
      t.integer :epoch
      t.integer :height
      t.bigint :parent_slot
      t.bigint :block_time

      t.timestamps

      t.index %i[slot_number]
    end

    create_table :blockchain_testnet_blocks do |t|
      t.bigint :slot_number
      t.string :blockhash
      t.integer :epoch
      t.integer :height
      t.bigint :parent_slot
      t.bigint :block_time

      t.timestamps

      t.index %i[slot_number]
    end

    create_table :blockchain_pythnet_blocks do |t|
      t.bigint :slot_number
      t.string :blockhash
      t.integer :epoch
      t.integer :height
      t.bigint :parent_slot
      t.bigint :block_time

      t.timestamps

      t.index %i[slot_number]
    end
  end
end
