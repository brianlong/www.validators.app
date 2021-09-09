# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/gather_yesterday_sol_prices_from_coin_gecko.rb

# Script that runs 1-time per day, just after midnight UTC, 
# to the get the price data for the previous day.
require_relative('../../../config/environment')
require 'coin_gecko_logic'

include CoinGeckoLogic

# Create our initial payload with the input values
initial_payload = {
  client: SolPrices::ApiWrappers::CoinGecko.new,
  datetime: Time.now.utc.beginning_of_day,
  days: 1
}

p = Pipeline.new(200, initial_payload)
            .then(&get_prices_from_days)
            .then(&filter_prices_by_date)
            .then(&get_volumes_from_days)
            .then(&filter_volumes_by_date)
            .then(&add_epoch)
            .then(&save_sol_price)

