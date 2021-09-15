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

      assert_not_nil p.payload[:prices_from_exchange]
    end
  end

  test '#filter_prices_by_date' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_ohlc_prices)
                  .then(&filter_prices_by_date)

      assert_not_nil p.payload[:sol_price]
    end
  end

  test '#get_volumes_from_days' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_volumes_from_days)

      assert_not_nil p.payload[:volumes]
    end
  end

  test '#filter_volumes_by_date' do
    vcr_cassette(@namespace, @vcr_name) do
      p = Pipeline.new(200, @initial_payload)
                  .then(&get_volumes_from_days)
                  .then(&filter_volumes_by_date)

      assert_not_nil p.payload[:sol_price_volume]
    end
  end

  test '#save_sol_price' do
    vcr_cassette(@namespace, @vcr_name) do
      assert_difference 'SolPrice.count' do
        p = Pipeline.new(200, @initial_payload)
                    .then(&get_ohlc_prices)
                    .then(&filter_prices_by_date)
                    .then(&get_volumes_from_days)
                    .then(&filter_volumes_by_date)
                    .then(&find_epoch)
                    .then(&save_sol_price)
              
        sol_price_db = SolPrice.last

        assert_equal sol_price_db.volume, p.payload.dig(:sol_price, :volume)
        assert_equal sol_price_db.open, p.payload.dig(:sol_price, :open)
        assert_equal sol_price_db.close, p.payload.dig(:sol_price, :close)
        assert_equal sol_price_db.high, p.payload.dig(:sol_price, :high)
        assert_equal sol_price_db.low, p.payload.dig(:sol_price, :low)
        assert_equal sol_price_db.epoch_testnet, p.payload.dig(:sol_price, :epoch_testnet)
        assert_equal sol_price_db.epoch_mainnet, p.payload.dig(:sol_price, :epoch_mainnet)
      end
    end
  end
end
