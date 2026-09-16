class AddSlotNumberIndexToBlockchainSlots < ActiveRecord::Migration[6.1]
  def change
    add_index :blockchain_mainnet_slots, :slot_number
    add_index :blockchain_testnet_slots, :slot_number
  end
end
