class AddCreditsCurrent < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_account_histories, :credits_current, :bigint
  end
end
