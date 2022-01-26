class AddMoreFeesToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :withdrawal_fee, :float
    add_column :stake_pools, :deposit_fee, :float
  end
end
