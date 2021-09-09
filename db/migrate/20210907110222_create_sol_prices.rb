class CreateSolPrices < ActiveRecord::Migration[6.1]
  def change
    create_table :sol_prices do |t|
      t.integer "exchange"
      t.integer "currency"
      t.integer "epoch_mainnet"
      t.integer "epoch_testnet"
      t.decimal "open", precision: 40, scale: 20
      t.decimal "close", precision: 40, scale: 20
      t.decimal "high", precision: 40, scale: 20
      t.decimal "low", precision: 40, scale: 20
      t.decimal "volume", precision: 40, scale: 20
      t.datetime "datetime_from_exchange"
      t.datetime "created_at", precision: 6, null: false
      t.datetime "updated_at", precision: 6, null: false
    end
  end
end
