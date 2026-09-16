class AddIndexesToBlockchainTestnetSlots < ActiveRecord::Migration[6.1]
  def change
    add_index :blockchain_testnet_slots, :slot_number
    add_index :blockchain_testnet_slots, %i[status created_at]
  end
end
