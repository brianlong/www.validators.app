class AddFailsCountToPingThingStats < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_stats, :fails_count, :integer
  end
end
