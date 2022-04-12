# frozen_string_literal: true

# CreateValidatorBlockHistories
class CreateValidatorBlockHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :validator_block_histories do |t|
      t.references :validator, null: false, foreign_key: true
      t.integer :epoch
      t.integer :leader_slots
      t.integer :blocks_produced
      t.integer :skipped_slots
      t.decimal :skipped_slot_percent, precision: 10, scale: 4
      t.timestamps
    end
    add_index :validator_block_histories, %i[validator_id epoch]
    add_index :validator_block_histories, %i[validator_id created_at]
  end
end
