class AddP90ToPingThingStats < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_stats, :p90, :float
  end
end
