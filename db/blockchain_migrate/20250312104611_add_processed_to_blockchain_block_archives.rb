class AddProcessedToBlockchainBlockArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_mainnet_block_archives, :processed, :boolean, default: false
    add_column :blockchain_testnet_block_archives, :processed, :boolean, default: false
    add_column :blockchain_pythnet_block_archives, :processed, :boolean, default: false
  end
end
