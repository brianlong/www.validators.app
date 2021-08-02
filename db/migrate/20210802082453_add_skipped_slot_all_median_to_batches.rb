class AddSkippedSlotAllMedianToBatches < ActiveRecord::Migration[6.1]
  def change
    add_column :batches, :skipped_slot_all_median, :float
  end
end
