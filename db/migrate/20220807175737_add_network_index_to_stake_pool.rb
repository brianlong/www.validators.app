class AddNetworkIndexToStakePool < ActiveRecord::Migration[6.1]
  def change
    add_index :stake_pools, :network
  end
end
