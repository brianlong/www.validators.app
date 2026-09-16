class AddStatusCreatedAtIndexToBlockchainMainnetSlots < ActiveRecord::Migration[6.1]
  def change
    add_index :blockchain_mainnet_slots, %i[status created_at]
  end
end
