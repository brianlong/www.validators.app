class AddRoiFieldsToEpochWallClocks < ActiveRecord::Migration[6.1]
  def change
    add_column :epoch_wall_clocks, :total_rewards, :bigint
    add_column :epoch_wall_clocks, :total_active_stake, :bigint
  end
end
