class RemoveFtxAttributesFromSolPrice < ActiveRecord::Migration[6.1]
  def change
    remove_column :sol_prices, :close, :string
    remove_column :sol_prices, :high, :string
    remove_column :sol_prices, :low, :string
    remove_column :sol_prices, :open, :string
  end
end
