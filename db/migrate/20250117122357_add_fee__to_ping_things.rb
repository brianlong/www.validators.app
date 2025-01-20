class AddFeeToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :fee, :bigint
  end
end
