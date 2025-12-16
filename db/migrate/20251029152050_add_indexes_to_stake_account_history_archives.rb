class AddIndexesToStakeAccountHistoryArchives < ActiveRecord::Migration[6.1]
  def change
    add_index :stake_account_history_archives, [:withdrawer, :network]
    add_index :stake_account_history_archives, :epoch
  end
end
