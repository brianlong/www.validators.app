class SplitBlockchainSlotToSeparateNetworks < ActiveRecord::Migration[6.1]
  def change
    drop_table :blockchain_slots

    create_table :blockchain_mainnet_slots do |t|
      t.bigint :slot_number
      t.string :leader
      t.integer :epoch
      t.integer :status, default: 0

      t.timestamps

      t.index %i[epoch leader]
    end

    create_table :blockchain_testnet_slots do |t|
      t.bigint :slot_number
      t.string :leader
      t.integer :epoch
      t.integer :status, default: 0

      t.timestamps

      t.index %i[epoch leader]
    end

    create_table :blockchain_pythnet_slots do |t|
      t.bigint :slot_number
      t.string :leader
      t.integer :epoch
      t.integer :status, default: 0

      t.timestamps

      t.index %i[epoch leader]
    end
  end
end
