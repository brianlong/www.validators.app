class CreatePingThingFeeStats < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_fee_stats do |t|
      t.string :network
      t.float :fee
      t.float :average_time
      t.float :median_time
      t.float :p90_time
      t.float :min_time
      t.float :min_slot_latency
      t.float :median_slot_latency
      t.float :p90_slot_latency

      t.timestamps
    end
  end
end
