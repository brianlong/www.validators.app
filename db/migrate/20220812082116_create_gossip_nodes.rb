class CreateGossipNodes < ActiveRecord::Migration[6.1]
  def change
    create_table :gossip_nodes do |t|
      t.string :identity
      t.string :network
      t.string :ip
      t.integer :tpu_port
      t.integer :gossip_port
      t.string :version

      t.timestamps
      t.index [:network, :identity]
    end
  end
end
