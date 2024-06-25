class CreateBlockchainSlotArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_slot_archives do |t|
      t.bigint :slot_number
      t.string :leader
      t.string :network
      t.integer :epoch
      t.integer :status
      
      t.timestamps
    end
  end
end
