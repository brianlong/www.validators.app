class AddTokenToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :token, :string
  end
end
