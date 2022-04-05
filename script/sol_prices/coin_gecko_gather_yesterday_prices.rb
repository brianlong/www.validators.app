# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/sol_prices/coin_gecko_gather_historical_prices.rb

# Script that runs 1-time per day, just after midnight UTC,
# to the get the price data for the previous day.
require_relative('../../config/environment')

include SolPrices::CoinGeckoLogic
include SolPrices::SharedLogic
include PipelineLogic

# Create our initial payload with the input values
initial_payload = {
  exchange: SolPrice.exchanges[:coin_gecko],
  client: ApiClients::CoinGeckoClient.new,
  datetime: DateTime.current.beginning_of_day - 1.day
}

p = Pipeline.new(200, initial_payload)
            .then(&get_historical_average_price)
            .then(&assign_epochs)
            .then(&save_sol_prices)
            .then(&log_info)
            .then(&log_errors)


