class DropBlocks < ActiveRecord::Migration[6.1]
  def change
    drop_table :blockchain_mainnet_blocks, if_exists: true
    drop_table :blockchain_testnet_blocks, if_exists: true
    drop_table :blockchain_pythnet_blocks, if_exists: true
  end
end
