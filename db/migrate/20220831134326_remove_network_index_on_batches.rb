class RemoveNetworkIndexOnBatches < ActiveRecord::Migration[6.1]
  def change
    remove_index :batches, :network
  end
end
