class AddIndexToPingThingReportedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :ping_things, :reported_at
  end
end
