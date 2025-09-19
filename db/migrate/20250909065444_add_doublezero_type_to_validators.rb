class AddDoublezeroTypeToValidators < ActiveRecord::Migration[6.1]
  def change
    add_column :validators, :doublezero_type, :integer, default: 0
  end
end
