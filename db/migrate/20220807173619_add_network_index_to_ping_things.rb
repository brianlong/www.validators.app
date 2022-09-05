class AddNetworkIndexToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_index :ping_things, :network
  end
end
