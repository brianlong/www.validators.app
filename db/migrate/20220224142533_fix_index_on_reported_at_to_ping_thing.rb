class FixIndexOnReportedAtToPingThing < ActiveRecord::Migration[6.1]
  def change
    remove_index :ping_things, :reported_at
    add_index :ping_things, [:reported_at, :network]
  end
end
