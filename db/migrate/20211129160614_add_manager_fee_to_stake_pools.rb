class AddManagerFeeToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :manager_fee, :float
  end
end
