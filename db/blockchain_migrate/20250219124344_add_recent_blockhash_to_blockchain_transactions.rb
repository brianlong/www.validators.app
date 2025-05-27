class AddRecentBlockhashToBlockchainTransactions < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_mainnet_transactions, :recent_blockhash, :string
    add_column :blockchain_testnet_transactions, :recent_blockhash, :string
    add_column :blockchain_pythnet_transactions, :recent_blockhash, :string
  end
end
