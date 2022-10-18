class AddActiveValidatorsCountToDataCenterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :data_center_stats, :active_validators_count, :integer
    add_column :data_center_stats, :active_gossip_nodes_count, :integer
  end
end
