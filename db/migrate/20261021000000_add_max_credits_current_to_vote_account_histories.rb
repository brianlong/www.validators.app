class AddMaxCreditsCurrentToVoteAccountHistories < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_account_histories, :max_credits_current, :bigint
  end
end
