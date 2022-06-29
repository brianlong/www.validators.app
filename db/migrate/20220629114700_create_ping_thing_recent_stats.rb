class CreatePingThingRecentStats < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_recent_stats do |t|
      t.integer :interval
      t.float :min
      t.float :max
      t.float :median
      t.float :p90
      t.integer :num_of_records
      t.string :network

      t.timestamps
    end
  end
end
