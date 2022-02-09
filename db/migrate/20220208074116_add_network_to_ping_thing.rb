class AddNetworkToPingThing < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :network, :string
  end
end
