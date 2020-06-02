# frozen_string_literal: true

# CreateValidatorBlockHistoryStats
class CreateValidatorBlockHistoryStats < ActiveRecord::Migration[6.0]
  def change
    create_table :validator_block_history_stats do |t|
      t.string :batch_id
      t.integer :epoch, unsigned: true
      t.bigint :start_slot, unsigned: true
      t.bigint :end_slot, unsigned: true
      t.integer :total_slots, unsigned: true
      t.integer :total_blocks_produced, unsigned: true
      t.integer :total_slots_skipped, unsigned: true
      t.timestamps
    end
    add_index :validator_block_history_stats, :batch_id
  end
end
