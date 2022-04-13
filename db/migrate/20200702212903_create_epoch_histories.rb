class CreateEpochHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :epoch_histories do |t|
      t.string :batch_uuid
      t.integer :epoch
      t.bigint :current_slot
      t.integer :slot_index
      t.integer :slots_in_epoch

      t.timestamps
    end
    add_index :epoch_histories, :batch_uuid
  end
end
