class AddReportedAtToPingThing < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :reported_at, :datetime
  end
end
