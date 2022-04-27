class CreatePingThingStats < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_stats do |t|
      t.integer :interval
      t.float :min
      t.float :max
      t.float :median
      t.integer :num_of_records
      t.string :network
      t.datetime :time_from

      t.timestamps
    end
  end
end
