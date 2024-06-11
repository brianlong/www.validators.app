class CreateBlockchainBlockArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_block_archives do |t|
      t.bigint :height
      t.bigint :block_time
      t.string :blockhash
      t.bigint :parent_slot
      t.bigint :slot_number
      
      t.timestamps
    end
  end
end
