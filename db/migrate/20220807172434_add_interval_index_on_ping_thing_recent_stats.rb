class AddIntervalIndexOnPingThingRecentStats < ActiveRecord::Migration[6.1]
  def change
    add_index :ping_thing_recent_stats, [:network, :interval]
  end
end
