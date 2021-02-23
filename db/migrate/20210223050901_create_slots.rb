class CreateSlots < ActiveRecord::Migration[6.0]
  def change
    create_table :slots do |t|
      t.string :network
      t.bigint :epoch
      t.bigint :slot_number
      t.string :leader_account
      t.boolean :skipped
      t.bigint :block_unix_time
      t.datetime :block_created_at
      t.text :commitment_level
      t.timestamps
    end
    
    add_index :slots, [:network, :epoch, :slot_number], unique: true
    add_index :slots, [:network, :slot_number]
  end
end
