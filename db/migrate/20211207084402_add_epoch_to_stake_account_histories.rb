class AddEpochToStakeAccountHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :stake_account_histories, :epoch, :integer
  end
end
