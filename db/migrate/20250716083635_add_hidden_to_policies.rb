class AddHiddenToPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :hidden, :boolean, default: false, null: false
  end
end
