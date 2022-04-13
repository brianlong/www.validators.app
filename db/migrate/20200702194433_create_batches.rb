# frozen_string_literal: true

# Create the batches table
class CreateBatches < ActiveRecord::Migration[6.1]
  def change
    create_table :batches do |t|
      t.string :uuid

      t.timestamps
    end
    add_index :batches, :uuid
    add_index :batches, :created_at
  end
end
