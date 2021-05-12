class AddSkippedVotePercentMovingAverageToVoteAccountHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_account_histories, :skipped_vote_percent_moving_average, :decimal, precision: 10, scale: 4
  end
end
