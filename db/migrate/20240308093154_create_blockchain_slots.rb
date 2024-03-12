class CreateBlockchainSlots < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_slots do |t|
      t.bigint :slot_number
      t.string :leader
      t.string :network
      t.integer :epoch
      t.boolean :has_block

      t.timestamps

      t.index %i[network epoch leader]
    end
  end
end
