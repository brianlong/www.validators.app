class AddScoredAtToBatch < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :gathered_at, :datetime
    add_column :batches, :scored_at, :datetime
  end
end
