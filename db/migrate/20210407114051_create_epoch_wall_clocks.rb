class CreateEpochWallClocks < ActiveRecord::Migration[6.1]
  def change
    create_table :epoch_wall_clocks do |t|
      t.integer :epoch
      t.string :network
      t.bigint :starting_slot
      t.integer :slots_in_epoch

      t.timestamps
      t.index [:network, :epoch], unique: true
    end
  end
end
