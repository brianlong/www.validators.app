class FixExplorerStakeAccountsIndex < ActiveRecord::Migration[6.1]
  def up
    remove_index :explorer_stake_accounts, name: "index_explorer_stake_accounts_on_epoch_and_network"
    add_index :explorer_stake_accounts, [:network, :epoch, :active_stake],
              name: "index_explorer_stake_accounts_on_network_epoch_active_stake"
  end

  def down
    remove_index :explorer_stake_accounts, name: "index_explorer_stake_accounts_on_network_epoch_active_stake"
    add_index :explorer_stake_accounts, [:epoch, :network],
              name: "index_explorer_stake_accounts_on_epoch_and_network"
  end
end
