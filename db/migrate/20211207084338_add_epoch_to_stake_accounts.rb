class AddEpochToStakeAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_accounts, :epoch, :integer
  end
end
