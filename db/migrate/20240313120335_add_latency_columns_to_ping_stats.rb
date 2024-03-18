class AddLatencyColumnsToPingStats < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_recent_stats, :min_slot_latency, :integer
    add_column :ping_thing_recent_stats, :p90_slot_latency, :integer
    add_column :ping_thing_user_stats, :min_slot_latency, :integer
    add_column :ping_thing_user_stats, :p90_slot_latency, :integer
  end
end
