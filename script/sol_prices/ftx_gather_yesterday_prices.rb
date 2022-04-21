# frozen_string_literal: true

# RAILS_ENV=production bundle exec rails r script/sol_prices/ftx_gather_yesterday_prices.rb

require_relative '../../config/environment'

include SolPrices::FtxLogic
include SolPrices::SharedLogic
include PipelineLogic

# Create our initial payload with the input values
initial_payload = {
  exchange: SolPrice.exchanges[:ftx],
  client: FtxClient.new,
  start_time: DateTime.current.beginning_of_day - 1.day,
  end_time: DateTime.current.end_of_day - 1.day,
  resolution: 86400 # interval of returned data
}

p = Pipeline.new(200, initial_payload)
            .then(&get_historical_prices)
            .then(&assign_epochs)
            .then(&save_sol_prices)
            .then(&log_info)
            .then(&log_errors)


