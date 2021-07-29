class AddAverageSkippedSlotPercentToBatches < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :average_skipped_slot_percent, :float
  end
end
