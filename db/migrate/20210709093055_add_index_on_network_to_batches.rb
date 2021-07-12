class AddIndexOnNetworkToBatches < ActiveRecord::Migration[6.1]
  def change
    add_index :batches, :network
  end
end
