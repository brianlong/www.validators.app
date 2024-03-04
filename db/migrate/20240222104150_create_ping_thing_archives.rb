class CreatePingThingArchives < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_thing_archives do |t|
      t.bigint :amount
      t.integer :user_id
      t.string :application
      t.integer :commitment_level
      t.string :network
      t.datetime :reported_at
      t.integer :response_time
      t.string :signature
      t.bigint :slot_landed
      t.bigint :slot_sent
      t.boolean :success
      t.string :transaction_type

      t.timestamps
    end
  end
end
