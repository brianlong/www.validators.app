class DropArchives < ActiveRecord::Migration[6.1]
  def change
    drop_table :blockchain_block_archives, if_exists: true
    drop_table :blockchain_transaction_archives, if_exists: true
    drop_table :blockchain_slot_archives, if_exists: true
  end
end
