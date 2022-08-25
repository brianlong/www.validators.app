class RemoveIpIndexFromGossipNodes < ActiveRecord::Migration[6.1]
  def change
    remove_index :gossip_nodes, :ip, if_exists: true
  end
end
