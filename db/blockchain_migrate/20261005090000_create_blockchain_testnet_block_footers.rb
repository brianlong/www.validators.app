class CreateBlockchainTestnetBlockFooters < ActiveRecord::Migration[6.1]
  def change
    create_table :blockchain_testnet_block_footers do |t|
      t.bigint :slot_number, null: false
      t.integer :epoch, null: false
      t.string :leader
      t.bigint :bank_id
      t.binary :bank_hash, limit: 32
      t.bigint :block_producer_time_nanos
      t.string :block_user_agent

      t.bigint :final_cert_slot
      t.integer :finalization
      t.column :final_signers, "varbinary(2048)"
      t.column :final_notar_signers, "varbinary(2048)"

      t.bigint :notar_reward_slot
      t.column :notar_reward_signers, "varbinary(2048)"

      t.bigint :skip_reward_slot
      t.column :skip_reward_signers, "varbinary(2048)"

      t.boolean :processed, default: false, null: false

      t.timestamps
    end

    add_index :blockchain_testnet_block_footers, :slot_number, unique: true,
              name: "index_testnet_block_footers_on_slot_number"
    add_index :blockchain_testnet_block_footers, %i[processed slot_number],
              name: "index_testnet_block_footers_on_processed_slot"
    add_index :blockchain_testnet_block_footers, :created_at,
              name: "index_testnet_block_footers_on_created_at"
  end
end
