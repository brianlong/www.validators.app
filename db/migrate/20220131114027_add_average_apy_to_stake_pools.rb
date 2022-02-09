class AddAverageApyToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :average_apy, :float
  end
end
