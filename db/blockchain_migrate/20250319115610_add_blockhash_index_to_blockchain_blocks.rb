class AddBlockhashIndexToBlockchainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_index :blockchain_mainnet_blocks, :blockhash
    add_index :blockchain_testnet_blocks, :blockhash
    add_index :blockchain_pythnet_blocks, :blockhash
  end
end
