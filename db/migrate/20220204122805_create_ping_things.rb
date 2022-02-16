class CreatePingThings < ActiveRecord::Migration[6.1]
  def change
    create_table :ping_things do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.bigint :amount
      t.string :signature
      t.integer :response_time
      t.string :transaction_type

      t.timestamps
    end
  end
end
