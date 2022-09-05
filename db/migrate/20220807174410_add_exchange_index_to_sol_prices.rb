class AddExchangeIndexToSolPrices < ActiveRecord::Migration[6.1]
  def change
    add_index :sol_prices, [:datetime_from_exchange, :exchange]
  end
end
