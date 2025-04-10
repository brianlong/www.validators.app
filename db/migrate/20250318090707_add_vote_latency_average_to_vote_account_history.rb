class AddVoteLatencyAverageToVoteAccountHistory < ActiveRecord::Migration[6.1]
  def change
    add_column :vote_account_histories, :vote_latency_average, :float
  end
end
