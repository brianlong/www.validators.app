# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/gather_yesterday_sol_prices_from_coin_gecko.rb

# Script that runs 1-time per day, just after midnight UTC, 
# to the get the price data for the previous day.
require_relative '../../../config/environment'
require 'coin_gecko_logic'

include CoinGeckoLogic

# Create our initial payload with the input values
initial_payload = {
  client: SolPrices::ApiWrappers::CoinGecko.new,
  datetime: Time.now.utc.beginning_of_day.to_datetime,
  days: 'max'
}

p = Pipeline.new(200, initial_payload)
            .then(&get_prices_from_days)
            .then(&save_sol_prices)

