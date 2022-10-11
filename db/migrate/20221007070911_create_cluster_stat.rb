class CreateClusterStat < ActiveRecord::Migration[6.1]
  def change
    create_table :cluster_stats do |t|
      t.bigint :total_active_stake
      t.string :network

      t.timestamps
    end
  end
end
