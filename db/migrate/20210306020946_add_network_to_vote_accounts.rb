class AddNetworkToVoteAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_accounts, :network, :string
    add_index :vote_accounts, [:network, :account]
  end
end
