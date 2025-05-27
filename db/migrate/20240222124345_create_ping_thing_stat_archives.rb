class CreatePingThingStatArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_stat_archives do |t|
      t.integer :average_slot_latency
      t.integer :interval
      t.float :max
      t.float :median
      t.float :min
      t.string :network
      t.integer :num_of_records
      t.datetime :time_from
      t.integer :tps
      t.bigint :transactions_count
      
      t.timestamps
    end
  end
end
