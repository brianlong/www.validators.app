class ConvertKindToInteger < ActiveRecord::Migration[6.1]
  def change
    change_column :policies, :kind, :integer
    add_index :policies, [:network, :kind]
  end
end
