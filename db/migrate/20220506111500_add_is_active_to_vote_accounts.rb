class AddIsActiveToVoteAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_accounts, :is_active, :boolean, default: true
  end
end
