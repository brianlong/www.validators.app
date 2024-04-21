class AddStatusToBlockchainSlots < ActiveRecord::Migration[6.1]
  def change
    add_column :blockchain_slots, :status, :integer, default: 0
    remove_column :blockchain_slots, :has_block, :boolean

    add_index :blockchain_slots, %i[network slot_number]
    add_index :blockchain_slots, %i[network status epoch]
  end
end
