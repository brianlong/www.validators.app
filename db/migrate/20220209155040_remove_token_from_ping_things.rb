class RemoveTokenFromPingThings < ActiveRecord::Migration[6.1]
  def change
    remove_column :ping_things, :token, :string
  end
end
