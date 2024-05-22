class AddIndexToBlockchainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_index :blockchain_blocks, %i[network slot_number]
  end
end
