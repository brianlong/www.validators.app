# frozen_string_literal: true

# CreatePingTimeStats
class CreatePingTimeStats < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_time_stats do |t|
      t.string :batch_id
      t.decimal :overall_min_time, precision: 10, scale: 3
      t.decimal :overall_max_time, precision: 10, scale: 3
      t.decimal :overall_average_time, precision: 10, scale: 3
      t.datetime :observed_at
      t.timestamps
    end
    add_index :ping_time_stats, :batch_id
  end
end
