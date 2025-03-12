class AddProcessedToBlockchainBlocks < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_mainnet_blocks, :processed, :boolean, default: false
    add_column :blockchain_testnet_blocks, :processed, :boolean, default: false
    add_column :blockchain_pythnet_blocks, :processed, :boolean, default: false

    add_index :blockchain_mainnet_blocks, [:created_at, :processed]
    add_index :blockchain_testnet_blocks, [:created_at, :processed]
    add_index :blockchain_pythnet_blocks, [:created_at, :processed]
  end
end
