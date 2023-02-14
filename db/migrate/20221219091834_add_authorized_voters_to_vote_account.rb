class AddAuthorizedVotersToVoteAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_accounts, :authorized_voters, :text
  end
end
