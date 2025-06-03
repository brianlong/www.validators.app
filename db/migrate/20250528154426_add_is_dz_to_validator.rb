class AddIsDzToValidator < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :is_dz, :boolean, default: false
  end
end
