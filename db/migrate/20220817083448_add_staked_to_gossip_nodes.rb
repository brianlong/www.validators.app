class AddStakedToGossipNodes < ActiveRecord::Migration[6.1]
  def change
    add_column :gossip_nodes, :staked, :boolean, default: false
  end
end
