class AddFinalizedToAlpenglowEpochRanks < ActiveRecord::Migration[6.1]
  def change
    add_column :alpenglow_epoch_ranks, :finalized, :boolean, default: false, null: false
  end
end
