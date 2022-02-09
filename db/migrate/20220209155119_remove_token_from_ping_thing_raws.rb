class RemoveTokenFromPingThingRaws < ActiveRecord::Migration[6.1]
  def change
    remove_column :ping_thing_raws, :token, :string
  end
end
