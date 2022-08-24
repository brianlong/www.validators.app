class ChangeIdentityToAccountInGossipNodes < ActiveRecord::Migration[6.1]
  def change
    rename_column :gossip_nodes, :identity, :account
    rename_column :gossip_nodes, :version, :software_version
  end
end
