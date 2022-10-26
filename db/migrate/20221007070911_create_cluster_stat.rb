class CreateClusterStat < ActiveRecord::Migration[6.1]
  def change
    create_table :cluster_stats do |t|
      t.bigint :total_active_stake
      t.string :network

      t.timestamps

      t.index [:network], name: "index_cluster_stat_on_network"
    end
  end
end
