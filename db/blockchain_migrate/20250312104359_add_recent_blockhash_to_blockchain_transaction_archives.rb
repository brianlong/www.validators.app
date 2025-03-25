class AddRecentBlockhashToBlockchainTransactionArchives < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_mainnet_transaction_archives, :recent_blockhash, :string
    add_column :blockchain_testnet_transaction_archives, :recent_blockhash, :string
    add_column :blockchain_pythnet_transaction_archives, :recent_blockhash, :string
  end
end
