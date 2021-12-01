class AddTickerToStakePools < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_pools, :ticker, :string
  end
end
