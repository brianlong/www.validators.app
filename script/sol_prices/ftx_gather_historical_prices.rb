# frozen_string_literal: true
#
# RAILS_ENV=production bundle exec rails r script/sol_prices/ftx_gather_historical_prices.rb

require_relative '../../config/environment'

include SolPrices::FtxLogic
include SolPrices::SharedLogic

# Create our initial payload with the input values
initial_payload = {
  exchange: SolPrice.exchanges[:ftx],
  client: SolPrices::ApiWrappers::Ftx.new,
  start_time: DateTime.new(2020,7,27), # first day when sol appeared
  resolution: 86400 # interval of returned data
}

p = Pipeline.new(200, initial_payload)
            .then(&get_historical_prices)
            .then(&assign_epochs)
            .then(&save_sol_prices)
            .then(&log_info)
            .then(&log_errors)

