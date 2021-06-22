class AddSkippedVoteFieldsToBatches < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :skipped_vote_all_median, :float
    add_column :batches, :best_skipped_vote, :float
  end
end
