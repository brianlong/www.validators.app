class AddEpochIndexToEpochWallClock < ActiveRecord::Migration[6.1]
  def change
    add_index :epoch_wall_clocks, :epoch
  end
end
