class DropPythnetArchives < ActiveRecord::Migration[6.1]
  def change
    drop_table :blockchain_pythnet_block_archives, if_exists: true
    drop_table :blockchain_pythnet_slot_archives, if_exists: true
    drop_table :blockchain_pythnet_transaction_archives, if_exists: true
  end
end
