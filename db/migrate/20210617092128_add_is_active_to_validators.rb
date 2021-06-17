class AddIsActiveToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :is_active, :boolean, default: true
  end
end
