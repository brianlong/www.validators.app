class CreateBlockchainBlocks < ActiveRecord::Migration[6.1]
  def change
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
