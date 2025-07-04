class AddSymbolToPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :symbol, :string
  end
end
