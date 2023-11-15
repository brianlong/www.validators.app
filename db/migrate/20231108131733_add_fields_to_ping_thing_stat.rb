class AddFieldsToPingThingStat < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_stats, :transactions_count, :bigint
    add_column :ping_thing_stats, :tps, :integer
  end
end
