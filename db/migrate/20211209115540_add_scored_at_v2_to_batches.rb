class AddScoredAtV2ToBatches < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :scored_at_v2, :datetime
    add_index :batches, [:network, :scored_at_v2]
  end
end
