class AddNetworkToPingThingRaw < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_thing_raws, :network, :string
  end
end
