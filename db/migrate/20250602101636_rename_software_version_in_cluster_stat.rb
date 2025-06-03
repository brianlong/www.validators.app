class RenameSoftwareVersionInClusterStat < ActiveRecord::Migration[6.1]
  def change
    rename_column :cluster_stats, :software_version, :software_versions
    change_column :cluster_stats, :software_versions, :json
  end
end
