class AddAverageLifetimeToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :average_lifetime, :integer
  end
end
