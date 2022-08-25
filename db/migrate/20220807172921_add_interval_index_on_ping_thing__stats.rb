class AddIntervalIndexOnPingThingStats < ActiveRecord::Migration[6.1]
  def change
    add_index :ping_thing_stats, [:network, :interval]
  end
end
