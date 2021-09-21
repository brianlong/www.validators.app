# frozen_string_literal: true

# Argument is optional, when is omitted max will be used.
# Valid values: 1/7/14/30/90/180/365/'max'. Defaults to 7 days.
# 
# RAILS_ENV=production bundle exec rails r script/gather_historical_prices_from_coin_gecko.rb 365 

require_relative '../../config/environment'

include SolPrices::CoinGeckoLogic
include SolPrices::SharedLogic

# Create our initial payload with the input values
datetime = DateTime.new(2020,7,27)

initial_payload = {
  exchange: SolPrice.exchanges[:coin_gecko],
  client: SolPrices::ApiWrappers::CoinGecko.new
}

begin
  until datetime > DateTime.current
    initial_payload[:datetime] = datetime

    p = Pipeline.new(200, initial_payload)
                .then(&get_historical_average_price)
                .then(&assign_epochs)
                .then(&save_sol_prices)
                .then(&log_info)

    datetime = datetime + 1.day

    sleep 1
  end

rescue StandardError => e
  p e
end
