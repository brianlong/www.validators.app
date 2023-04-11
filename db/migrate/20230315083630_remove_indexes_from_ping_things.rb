class RemoveIndexesFromPingThings < ActiveRecord::Migration[6.1]
  def change
    remove_index :ping_things, name: "index_ping_things_on_created_at_and_network_and_transaction_type"
    remove_index :ping_things, name: "index_ping_things_on_created_at_and_network_and_user_id"
  end
end
