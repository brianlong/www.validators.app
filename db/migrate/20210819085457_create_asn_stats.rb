class CreateAsnStats < ActiveRecord::Migration[6.1]
  def change
    create_table :asn_stats do |t|
      t.float :vote_distance_moving_average
      t.integer :traits_autonomous_system_number
      t.datetime :calculated_at
      t.integer :population
      t.float :active_stake
      t.text :data_centers
      t.string :network
      
      t.timestamps
    end
  end
end
