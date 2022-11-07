class AddDistanceAndSkippedToClusterStat < ActiveRecord::Migration[6.1]
  def change
    add_column :cluster_stats, :root_distance, :json
    add_column :cluster_stats, :vote_distance, :json
    add_column :cluster_stats, :skipped_slots, :json
    add_column :cluster_stats, :skipped_votes, :json
  end
end
