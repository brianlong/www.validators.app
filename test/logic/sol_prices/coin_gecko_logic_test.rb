# frozen_string_literal: true

require 'test_helper'

# CoinGeckoLogicTest
class SolPrices::CoinGeckoLogicTest < ActiveSupport::TestCase
  include CoinGeckoLogic
  include SharedLogic
  include VcrHelper

  def setup
    # Create our initial payload with the input values
    @initial_payload = {
      client: CoinGeckoClient.new,
      datetime: DateTime.new(2021,9,8),
      days: 1
    }
    @namespace = File.join('logic', 'coin_gecko_logic')
    @vcr_name = 'coin_gecko_logic'

    create(:epoch_history, network: 'testnet', epoch: 200)
    create(:epoch_history, network: 'mainnet', epoch: 205)
  end

  test '#get_historical_average_price' do
    vcr_cassette(@namespace, __method__) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_historical_average_price)

      assert_equal 1, p.payload[:prices_from_exchange].size
    end
  end

  test '#get_daily_historical_average_price' do
    vcr_cassette(@namespace, __method__) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_daily_historical_average_price)

      assert_equal 531, p.payload[:prices_from_exchange].size
    end
  end

  test '#get_ohlc_prices' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_ohlc_prices)

      assert_equal 49, p.payload[:prices_from_exchange].size
    end
  end
end
