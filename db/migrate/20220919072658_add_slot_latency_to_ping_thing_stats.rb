class AddSlotLatencyToPingThingStats < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_stats, :average_slot_latency, :integer
  end
end
