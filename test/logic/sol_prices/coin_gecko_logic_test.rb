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
      client: SolPrices::ApiWrappers::CoinGecko.new,
      datetime: DateTime.new(2021,9,8),
      days: 1
    }
    @namespace = File.join('logic', 'coin_gecko_logic')
    @vcr_name = 'coin_gecko_logic'

    create(:epoch_history, network: 'testnet', epoch: 200)
    create(:epoch_history, network: 'mainnet', epoch: 205)
  end

  test '#get_ohlc_prices' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_ohlc_prices)

      assert_equal 49, p.payload[:prices_from_exchange].size
    end
  end

  test '#filter_prices_by_date' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_ohlc_prices)
                  .then(&filter_prices_by_date)

      assert_equal 1, p.payload[:prices_from_exchange].size
    end
  end

  test '#get_volumes_from_days' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_volumes_from_days)

      assert_equal 2, p.payload[:volumes].size
      assert_equal 16_149_087_501.300968, p.payload[:volumes].first[:volume]
    end
  end

  test '#filter_volumes_by_date' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_volumes_from_days)
                  .then(&filter_volumes_by_date)

      assert_equal 16_149_087_501.300968,  p.payload[:volume]
    end
  end
end
