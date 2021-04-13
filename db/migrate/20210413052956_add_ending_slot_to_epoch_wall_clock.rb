class AddEndingSlotToEpochWallClock < ActiveRecord::Migration[6.1]
  def change
    add_column :epoch_wall_clocks, :ending_slot, :bigint
  end
end
