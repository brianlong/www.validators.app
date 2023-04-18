class AddIndexToActiveStake < ActiveRecord::Migration[6.1]
  def change
    add_index :stake_accounts, :active_stake
  end
end
