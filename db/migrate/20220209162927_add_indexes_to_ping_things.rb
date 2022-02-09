class AddIndexesToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_index :ping_things, [:created_at, :network, :transaction_type]
    add_index :ping_things, [:created_at, :network, :user_id]
  end
end
