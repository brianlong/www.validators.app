class RemoveBlockchainArchives < ActiveRecord::Migration[6.1]
  def change
    drop_table :blockchain_block_archives
    drop_table :blockchain_transaction_archives
    drop_table :blockchain_slot_archives
  end
end
