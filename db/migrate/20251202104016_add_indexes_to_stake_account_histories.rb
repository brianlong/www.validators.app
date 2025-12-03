class AddIndexesToStakeAccountHistories < ActiveRecord::Migration[6.1]
  def change
    add_index :stake_account_histories, :epoch
  end
end
