class DropPingTimeStatsTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :ping_time_stats
  end
end
