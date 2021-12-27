class AddApyToStakeAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_accounts, :apy, :float
  end
end
