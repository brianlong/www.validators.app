class AddAuthorizedWithdrawerToVoteAccountHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_account_histories, :authorized_withdrawer_before, :string
    add_column :vote_account_histories, :authorized_withdrawer_after, :string
  end
end
