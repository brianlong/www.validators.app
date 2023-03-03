class AddRoiToClusterStats < ActiveRecord::Migration[6.1]
  def change
    add_column :cluster_stats, :roi, :float
  end
end
