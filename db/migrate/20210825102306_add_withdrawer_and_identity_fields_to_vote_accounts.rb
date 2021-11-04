class AddWithdrawerAndIdentityFieldsToVoteAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_accounts, :validator_identity, :string
    add_column :vote_accounts, :authorized_withdrawer, :string
  end
end
