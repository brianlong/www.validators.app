class AddAverageSlotLatencyToPingThingRecentStats < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_recent_stats, :average_slot_latency, :float
  end
end
