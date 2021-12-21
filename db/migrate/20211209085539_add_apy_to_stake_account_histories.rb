class AddApyToStakeAccountHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_account_histories, :apy, :float
  end
end
