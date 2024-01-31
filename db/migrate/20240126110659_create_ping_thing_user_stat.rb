class CreatePingThingUserStat < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_user_stats do |t|
      t.float :average_slot_latency
      t.integer :interval
      t.float :min
      t.float :max
      t.float :median
      t.float :p90
      t.integer :num_of_records
      t.string :network
      t.references :user, null: false, foreign_key: true
      t.string :username
      t.integer :fails_count
      
      t.timestamps
    end
  end
end
