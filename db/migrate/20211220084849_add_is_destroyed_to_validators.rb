class AddIsDestroyedToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :is_destroyed, :boolean, default: :false
  end
end
