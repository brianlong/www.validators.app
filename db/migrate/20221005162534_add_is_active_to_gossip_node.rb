class AddIsActiveToGossipNode < ActiveRecord::Migration[6.1]
  def change
    add_column :gossip_nodes, :is_active, :boolean, default: true
    add_index :gossip_nodes, %i[network is_active]
  end
end
