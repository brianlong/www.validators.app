class AddNetworkIndexesToStakeAccountTables < ActiveRecord::Migration[6.1]
  def change
    add_index :stake_accounts, [:network, :active_stake]
    add_index :stake_account_histories, [:network, :epoch]
  end
end
