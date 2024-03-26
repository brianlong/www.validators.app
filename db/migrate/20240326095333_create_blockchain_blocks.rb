class CreateBlockchainBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_blocks do |t|
      t.bigint :height
      t.bigint :block_time
      t.string :hash
      t.bigint :parent_slot

      t.timestamps
    end
  end
end
