# frozen_string_literal: true

# Argument is optional, when is omitted max will be used.
# Valid values: 1/7/14/30/90/180/365/'max'. Defaults to 7 days.
# 
# RAILS_ENV=production bundle exec rails r script/gather_historical_prices_from_coin_gecko.rb 365 

require_relative '../../../config/environment'
require 'coin_gecko_logic'

include CoinGeckoLogic

# Create our initial payload with the input values
initial_payload = {
  client: SolPrices::ApiWrappers::CoinGecko.new,
  datetime: Time.now.utc.beginning_of_day.to_datetime,
  days: ARGV[0] || 'max'
}

p = Pipeline.new(200, initial_payload)
            .then(&get_prices_from_days)
            .then(&save_sol_prices)

