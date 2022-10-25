class AddQuantitiesToClusterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :cluster_stats, :validator_count, :integer
    add_column :cluster_stats, :nodes_count, :integer
    add_column :cluster_stats, :software_version, :string
  end
end
