class DropTransactions < ActiveRecord::Migration[6.1]
  def change
    drop_table :blockchain_mainnet_transactions, if_exists: true
    drop_table :blockchain_testnet_transactions, if_exists: true
    drop_table :blockchain_pythnet_transactions, if_exists: true
  end
end
