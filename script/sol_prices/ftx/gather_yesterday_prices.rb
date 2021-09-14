# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/sol_prices/ftx/gather_yesterday_prices_from.rb 

require_relative '../../../config/environment'

include SolPrices::FtxLogic
include SolPrices::SharedLogic

# Create our initial payload with the input values
initial_payload = {
  exchange: SolPrice.exchanges[:ftx],
  client: SolPrices::ApiWrappers::FtxMarket.new,
  start_time: Date.yesterday.to_datetime,
  end_time: Date.yesterday.to_datetime,
  resolution: 86400 # interval of returned data
}

p = Pipeline.new(200, initial_payload)
            .then(&get_historical_prices)
            .then(&save_sol_prices)

