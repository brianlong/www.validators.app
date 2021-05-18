class AddScoredAtIndexToBatches < ActiveRecord::Migration[6.1]
  def change
    add_index :batches, [:network, :scored_at]
  end
end
