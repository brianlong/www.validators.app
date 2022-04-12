# frozen_string_literal: true

# CreatePingTimes
class CreatePingTimes < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_times do |t|
      t.string :batch_id
      t.string :network
      t.string :from_account
      t.string :from_ip
      t.string :to_account
      t.string :to_ip
      t.decimal :min_ms, precision: 10, scale: 3
      t.decimal :avg_ms, precision: 10, scale: 3
      t.decimal :max_ms, precision: 10, scale: 3
      t.decimal :mdev, precision: 10, scale: 3
      t.datetime :observed_at
      t.timestamps
    end
    add_index :ping_times, :batch_id
    add_index :ping_times,
              %i[network from_account to_account created_at],
              name: 'ndx_network_from_to_account'
    add_index :ping_times, %i[network from_account created_at]
    add_index :ping_times, %i[network from_ip to_ip created_at]
    add_index :ping_times, %i[network from_ip created_at]
    add_index :ping_times,
              %i[network to_account from_account created_at],
              name: 'ndx_network_to_from_account'
    add_index :ping_times, %i[network to_account created_at]
    add_index :ping_times, %i[network to_ip from_ip created_at]
    add_index :ping_times, %i[network to_ip created_at]
  end
end
