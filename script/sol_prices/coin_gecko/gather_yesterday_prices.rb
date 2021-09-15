# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/sol_prices/gather_yesterday_prices.rb

# Script that runs 1-time per day, just after midnight UTC, 
# to the get the price data for the previous day.
require_relative('../../../config/environment')

include SolPrices::CoinGeckoLogic
include SolPrices::SharedLogic

# Create our initial payload with the input values
initial_payload = {
  exchange: SolPrice.exchanges[:coin_gecko],
  client: SolPrices::ApiWrappers::CoinGecko.new,
  datetime: DateTime.current.beginning_of_day,
  days: 1
}

p = Pipeline.new(200, initial_payload)
            .then(&get_ohlc_prices)
            .then(&filter_prices_by_date)
            .then(&get_volumes_from_days)
            .then(&filter_volumes_by_date)
            .then(&find_epoch)
            .then(&save_sol_price)
            .then(&log_info)


