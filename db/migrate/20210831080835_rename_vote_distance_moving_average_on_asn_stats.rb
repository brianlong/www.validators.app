class RenameVoteDistanceMovingAverageOnAsnStats < ActiveRecord::Migration[6.1]
  def change
    rename_column :asn_stats, :vote_distance_moving_average, :average_score
  end
end
