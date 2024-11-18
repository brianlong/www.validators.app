class AddRecentBlockhashToBlockchainTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_mainnet_transaction_archives, :recent_blockhash, :string
    add_column :blockchain_testnet_transaction_archives, :recent_blockhash, :string
    add_column :blockchain_pythnet_transaction_archives, :recent_blockhash, :string
    add_column :blockchain_mainnet_transactions, :recent_blockhash, :string
    add_column :blockchain_testnet_transactions, :recent_blockhash, :string
    add_column :blockchain_pythnet_transactions, :recent_blockhash, :string

    add_index :blockchain_mainnet_transactions, :epoch
    add_index :blockchain_testnet_transactions, :epoch
    add_index :blockchain_pythnet_transactions, :epoch
  end
end
