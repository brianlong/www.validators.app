class AddSkippedAfterAverageToBatches < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :skipped_after_all_average, :float, default: 0.0
  end
end
