class AddFailsCountToPingThingRecentStats < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_recent_stats, :fails_count, :integer
  end
end
