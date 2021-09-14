# frozen_string_literal: true
require 'test_helper'

# CoinGeckoLogicTest
class SolPrices::SharedLogicTest < ActiveSupport::TestCase
  include SolPrices::Parsers::CoinGecko
  include SolPrices::CoinGeckoLogic
  include SolPrices::FtxLogic
  include SolPrices::SharedLogic
  include VcrHelper

  def setup
    # Create our initial payload with the input values

    @namespace = File.join('logic', 'sol_prices', 'shared')
    @initial_payload = {}

    create(:epoch_history, network: 'testnet', epoch: 200)
    create(:epoch_history, network: 'mainnet', epoch: 205)
  end

  test '#save_sol_prices coin_gecko' do
    payload = @initial_payload.merge(
      {
        exchange: SolPrice.exchanges[:coin_gecko],
        client: SolPrices::ApiWrappers::CoinGecko.new,
        datetime: DateTime.new(2021,9,8),
        days: 'max'
      }
    )

    vcr_cassette(@namespace, __method__) do
      assert_difference 'SolPrice.count', 136 do
        p = Pipeline.new(200, payload)
                    .then(&get_ohlc_prices)
                    .then(&save_sol_prices)
      end
    end
  end

  test '#save_sol_prices ftx' do
    payload = @initial_payload.merge(
      {
        exchange: SolPrice.exchanges[:ftx],
        client: SolPrices::ApiWrappers::FtxMarket.new,
        start_time: DateTime.new(2021,9,8),
        resolution: 86400,
      }
    )


    vcr_cassette(@namespace, __method__) do
      assert_difference 'SolPrice.count', 3 do
        p = Pipeline.new(200, payload)
                    .then(&get_historical_prices)
                    .then(&save_sol_prices)

        assert_not_nil p.payload[:prices_from_exchange]
      end
    end
  end

  test '#add_epoch' do
    create(:epoch_history, network: 'testnet', epoch: 200)
    create(:epoch_history, network: 'mainnet', epoch: 205)
    
    p = Pipeline.new(200, @initial_payload)
                .then(&add_epoch)

    assert_not_nil p.payload[:epoch_testnet]
    assert_not_nil p.payload[:epoch_mainnet]
  end
end
