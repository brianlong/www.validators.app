class ChangeIdentityToAccountInGossipNodes < ActiveRecord::Migration[6.1]
  def change
    rename_column :gossip_nodes, :identity, :account

    remove_index :gossip_nodes, :ip
  end
end
