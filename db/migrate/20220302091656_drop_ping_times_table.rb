class DropPingTimesTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :ping_times
  end
end
