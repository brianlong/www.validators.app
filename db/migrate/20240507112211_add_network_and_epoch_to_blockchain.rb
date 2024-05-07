class AddNetworkAndEpochToBlockchain < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_blocks, :network, :string
    add_column :blockchain_blocks, :epoch, :integer

    add_column :blockchain_block_archives, :network, :string
    add_column :blockchain_block_archives, :epoch, :integer

    add_column :blockchain_transactions, :network, :string
    add_column :blockchain_transactions, :epoch, :integer

    add_column :blockchain_transaction_archives, :network, :string
    add_column :blockchain_transaction_archives, :epoch, :integer
  end
end
