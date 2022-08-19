class AddIndexOnScorableValidators < ActiveRecord::Migration[6.1]
  def change
    add_index :validators, [:network, :is_active, :is_destroyed]
  end
end
