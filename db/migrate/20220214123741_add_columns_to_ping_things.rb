class AddColumnsToPingThings < ActiveRecord::Migration[6.1]
  def change
    add_column :ping_things, :commitment_level, :integer
    add_column :ping_things, :success, :boolean, default: true
    add_column :ping_things, :application, :string
  end
end
