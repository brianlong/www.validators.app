class AddConsensusModsToValidator < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :consensus_mods, :boolean, default: false
  end
end
