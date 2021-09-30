class AddAveragePriceToSolPrices < ActiveRecord::Migration[6.1]
  def change
    add_column :sol_prices, :average_price, :decimal, precision: 40, scale: 20
  end
end
