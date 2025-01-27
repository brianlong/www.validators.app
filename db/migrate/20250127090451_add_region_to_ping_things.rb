class AddRegionToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :region, :string
  end
end
